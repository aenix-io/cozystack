/*
Copyright 2024 The Cozystack Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package server

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net"

	"github.com/aenix-io/cozystack/pkg/apis/apps/v1alpha1"
	"github.com/aenix-io/cozystack/pkg/apiserver"
	"github.com/aenix-io/cozystack/pkg/config"
	sampleopenapi "github.com/aenix-io/cozystack/pkg/generated/openapi"
	"github.com/spf13/cobra"
	utilerrors "k8s.io/apimachinery/pkg/util/errors"
	utilruntime "k8s.io/apimachinery/pkg/util/runtime"
	"k8s.io/apimachinery/pkg/util/version"
	"k8s.io/apiserver/pkg/endpoints/openapi"
	genericapiserver "k8s.io/apiserver/pkg/server"
	genericoptions "k8s.io/apiserver/pkg/server/options"
	utilfeature "k8s.io/apiserver/pkg/util/feature"
	utilversionpkg "k8s.io/apiserver/pkg/util/version"
	"k8s.io/component-base/featuregate"
	baseversion "k8s.io/component-base/version"
	"k8s.io/klog/v2"
	"k8s.io/kube-openapi/pkg/validation/spec"
	netutils "k8s.io/utils/net"
)

// AppsServerOptions holds the state for the Apps API server
type AppsServerOptions struct {
	RecommendedOptions *genericoptions.RecommendedOptions

	StdOut io.Writer
	StdErr io.Writer

	AlternateDNS []string

	// Add a field to store the configuration path
	ResourceConfigPath string

	// Add a field to store the configuration
	ResourceConfig *config.ResourceConfig
}

// NewAppsServerOptions returns a new instance of AppsServerOptions
func NewAppsServerOptions(out, errOut io.Writer) *AppsServerOptions {
	o := &AppsServerOptions{
		RecommendedOptions: genericoptions.NewRecommendedOptions(
			"",
			apiserver.Codecs.LegacyCodec(v1alpha1.SchemeGroupVersion),
		),

		StdOut: out,
		StdErr: errOut,
	}
	o.RecommendedOptions.Etcd = nil
	return o
}

// NewCommandStartAppsServer provides a CLI handler for the 'start apps-server' command
func NewCommandStartAppsServer(ctx context.Context, defaults *AppsServerOptions) *cobra.Command {
	o := *defaults
	cmd := &cobra.Command{
		Short: "Launch an Apps API server",
		Long:  "Launch an Apps API server",
		PersistentPreRunE: func(*cobra.Command, []string) error {
			return utilversionpkg.DefaultComponentGlobalsRegistry.Set()
		},
		RunE: func(c *cobra.Command, args []string) error {
			if err := o.Complete(); err != nil {
				return err
			}
			if err := o.Validate(args); err != nil {
				return err
			}
			if err := o.RunAppsServer(c.Context()); err != nil {
				return err
			}
			return nil
		},
	}
	cmd.SetContext(ctx)

	flags := cmd.Flags()
	o.RecommendedOptions.AddFlags(flags)

	// Add a flag for the config path
	flags.StringVar(&o.ResourceConfigPath, "config", "config.yaml", "Path to the resource configuration file")

	// The following lines demonstrate how to configure version compatibility and feature gates
	// for the "Apps" component according to KEP-4330.

	// Create a default version object for the "Apps" component.
	defaultAppsVersion := "1.1"
	// Register the "Apps" component in the global component registry,
	// associating it with its effective version and feature gate configuration.
	_, appsFeatureGate := utilversionpkg.DefaultComponentGlobalsRegistry.ComponentGlobalsOrRegister(
		apiserver.AppsComponentName, utilversionpkg.NewEffectiveVersion(defaultAppsVersion),
		featuregate.NewVersionedFeatureGate(version.MustParse(defaultAppsVersion)),
	)

	// Add feature gate specifications for the "Apps" component.
	utilruntime.Must(appsFeatureGate.AddVersioned(map[featuregate.Feature]featuregate.VersionedSpecs{
		// Example of adding feature gates:
		// "FeatureName": {{"v1", true}, {"v2", false}},
	}))

	// Register the standard kube component if it is not already registered in the global registry.
	_, _ = utilversionpkg.DefaultComponentGlobalsRegistry.ComponentGlobalsOrRegister(
		utilversionpkg.DefaultKubeComponent,
		utilversionpkg.NewEffectiveVersion(baseversion.DefaultKubeBinaryVersion),
		utilfeature.DefaultMutableFeatureGate,
	)

	// Set the version emulation mapping from the "Apps" component to the kube component.
	utilruntime.Must(utilversionpkg.DefaultComponentGlobalsRegistry.SetEmulationVersionMapping(
		apiserver.AppsComponentName, utilversionpkg.DefaultKubeComponent, AppsVersionToKubeVersion,
	))

	// Add flags from the global component registry.
	utilversionpkg.DefaultComponentGlobalsRegistry.AddFlags(flags)

	return cmd
}

// Complete fills in the fields that are not set
func (o *AppsServerOptions) Complete() error {
	// Load the configuration file
	cfg, err := config.LoadConfig(o.ResourceConfigPath)
	if err != nil {
		return fmt.Errorf("failed to load config from %s: %v", o.ResourceConfigPath, err)
	}
	o.ResourceConfig = cfg
	return nil
}

// Validate checks the correctness of the options
func (o AppsServerOptions) Validate(args []string) error {
	var allErrors []error
	allErrors = append(allErrors, o.RecommendedOptions.Validate()...)
	allErrors = append(allErrors, utilversionpkg.DefaultComponentGlobalsRegistry.Validate()...)
	return utilerrors.NewAggregate(allErrors)
}

// DeepCopySchema делает глубокую копию структуры spec.Schema
func DeepCopySchema(schema *spec.Schema) (*spec.Schema, error) {
	data, err := json.Marshal(schema)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal schema: %w", err)
	}

	var newSchema spec.Schema
	err = json.Unmarshal(data, &newSchema)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal schema: %w", err)
	}

	return &newSchema, nil
}

// Config returns the configuration for the API server based on AppsServerOptions
func (o *AppsServerOptions) Config() (*apiserver.Config, error) {
	// TODO: set the "real" external address
	if err := o.RecommendedOptions.SecureServing.MaybeDefaultWithSelfSignedCerts(
		"localhost", o.AlternateDNS, []net.IP{netutils.ParseIPSloppy("127.0.0.1")},
	); err != nil {
		return nil, fmt.Errorf("error creating self-signed certificates: %v", err)
	}

	// First, register the dynamic types
	err := v1alpha1.RegisterDynamicTypes(apiserver.Scheme, o.ResourceConfig)
	if err != nil {
		return nil, fmt.Errorf("failed to register dynamic types: %v", err)
	}

	serverConfig := genericapiserver.NewRecommendedConfig(apiserver.Codecs)

	serverConfig.OpenAPIConfig = genericapiserver.DefaultOpenAPIConfig(
		sampleopenapi.GetOpenAPIDefinitions, openapi.NewDefinitionNamer(apiserver.Scheme),
	)
	serverConfig.OpenAPIConfig.Info.Title = "Apps"
	serverConfig.OpenAPIConfig.Info.Version = "0.1"

	serverConfig.OpenAPIConfig.PostProcessSpec = func(swagger *spec.Swagger) (*spec.Swagger, error) {
		defs := swagger.Definitions

		// Verify the presence of the base Application/ApplicationList definitions
		appDef, exists := defs["com.github.aenix-io.cozystack.pkg.apis.apps.v1alpha1.Application"]
		if !exists {
			return swagger, fmt.Errorf("Application definition not found")
		}

		listDef, exists := defs["com.github.aenix-io.cozystack.pkg.apis.apps.v1alpha1.ApplicationList"]
		if !exists {
			return swagger, fmt.Errorf("ApplicationList definition not found")
		}

		// Iterate over all registered GVKs (e.g., Bucket, Database, etc.)
		for _, gvk := range v1alpha1.RegisteredGVKs {
			// This will be something like:
			// "com.github.aenix-io.cozystack.pkg.apis.apps.v1alpha1.Bucket"
			resourceName := fmt.Sprintf("com.github.aenix-io.cozystack.pkg.apis.apps.v1alpha1.%s", gvk.Kind)

			// 1. Create a copy of the base Application definition for the new resource
			newDef, err := DeepCopySchema(&appDef)
			if err != nil {
				return nil, fmt.Errorf("failed to deepcopy schema for %s: %w", gvk.Kind, err)
			}

			// 2. Update x-kubernetes-group-version-kind to match the new resource
			if newDef.Extensions == nil {
				newDef.Extensions = map[string]interface{}{}
			}
			newDef.Extensions["x-kubernetes-group-version-kind"] = []map[string]interface{}{
				{
					"group":   gvk.Group,
					"version": gvk.Version,
					"kind":    gvk.Kind,
				},
			}

			// 3. Save the new resource definition under the correct name
			defs[resourceName] = *newDef
			klog.V(6).Infof("PostProcessSpec: Added OpenAPI definition for %s\n", resourceName)

			// 4. Now handle the corresponding List type (e.g., BucketList).
			//    We'll start by copying the ApplicationList definition.
			listResourceName := fmt.Sprintf("com.github.aenix-io.cozystack.pkg.apis.apps.v1alpha1.%sList", gvk.Kind)
			newListDef, err := DeepCopySchema(&listDef)
			if err != nil {
				return nil, fmt.Errorf("failed to deepcopy schema for %sList: %w", gvk.Kind, err)
			}

			// 5. Update x-kubernetes-group-version-kind for the List definition
			if newListDef.Extensions == nil {
				newListDef.Extensions = map[string]interface{}{}
			}
			newListDef.Extensions["x-kubernetes-group-version-kind"] = []map[string]interface{}{
				{
					"group":   gvk.Group,
					"version": gvk.Version,
					"kind":    fmt.Sprintf("%sList", gvk.Kind),
				},
			}

			// 6. IMPORTANT: Fix the "items" reference so it points to the new resource
			//    rather than to "Application".
			if itemsProp, found := newListDef.Properties["items"]; found {
				if itemsProp.Items != nil && itemsProp.Items.Schema != nil {
					itemsProp.Items.Schema.Ref = spec.MustCreateRef("#/definitions/" + resourceName)
					newListDef.Properties["items"] = itemsProp
				}
			}

			// 7. Finally, save the new List definition
			defs[listResourceName] = *newListDef
			klog.V(6).Infof("PostProcessSpec: Added OpenAPI definition for %s\n", listResourceName)
		}

		// Remove the original Application/ApplicationList from the definitions
		delete(defs, "com.github.aenix-io.cozystack.pkg.apis.apps.v1alpha1.Application")
		delete(defs, "com.github.aenix-io.cozystack.pkg.apis.apps.v1alpha1.ApplicationList")

		swagger.Definitions = defs
		return swagger, nil
	}

	serverConfig.OpenAPIV3Config = genericapiserver.DefaultOpenAPIV3Config(
		sampleopenapi.GetOpenAPIDefinitions, openapi.NewDefinitionNamer(apiserver.Scheme),
	)
	serverConfig.OpenAPIV3Config.Info.Title = "Apps"
	serverConfig.OpenAPIV3Config.Info.Version = "0.1"

	serverConfig.FeatureGate = utilversionpkg.DefaultComponentGlobalsRegistry.FeatureGateFor(
		utilversionpkg.DefaultKubeComponent,
	)
	serverConfig.EffectiveVersion = utilversionpkg.DefaultComponentGlobalsRegistry.EffectiveVersionFor(
		apiserver.AppsComponentName,
	)

	if err := o.RecommendedOptions.ApplyTo(serverConfig); err != nil {
		return nil, err
	}

	config := &apiserver.Config{
		GenericConfig:  serverConfig,
		ResourceConfig: o.ResourceConfig,
	}
	return config, nil
}

// RunAppsServer launches a new AppsServer based on AppsServerOptions
func (o AppsServerOptions) RunAppsServer(ctx context.Context) error {
	config, err := o.Config()
	if err != nil {
		return err
	}

	server, err := config.Complete().New()
	if err != nil {
		return err
	}

	server.GenericAPIServer.AddPostStartHookOrDie("start-sample-server-informers", func(context genericapiserver.PostStartHookContext) error {
		config.GenericConfig.SharedInformerFactory.Start(context.Done())
		return nil
	})

	return server.GenericAPIServer.PrepareRun().RunWithContext(ctx)
}

// AppsVersionToKubeVersion defines the version mapping between the Apps component and kube
func AppsVersionToKubeVersion(ver *version.Version) *version.Version {
	if ver.Major() != 1 {
		return nil
	}
	kubeVer := utilversionpkg.DefaultKubeEffectiveVersion().BinaryVersion()
	// "1.2" corresponds to kubeVer
	offset := int(ver.Minor()) - 2
	mappedVer := kubeVer.OffsetMinor(offset)
	if mappedVer.GreaterThan(kubeVer) {
		return kubeVer
	}
	return mappedVer
}
