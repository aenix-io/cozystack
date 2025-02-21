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

package v1alpha1

import (
	"github.com/aenix-io/cozystack/pkg/config"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/klog/v2"
)

// GroupName holds the API group name.
const GroupName = "apps.cozystack.io"

var (
	RegisteredGVKs []schema.GroupVersionKind
)

// SchemeGroupVersion is group version used to register these objects
var SchemeGroupVersion = schema.GroupVersion{Group: GroupName, Version: "v1alpha1"}

var (
	// SchemeBuilder allows to add this group to a scheme.
	// TODO: move SchemeBuilder with zz_generated.deepcopy.go to k8s.io/api.
	// localSchemeBuilder and AddToScheme will stay in k8s.io/kubernetes.
	SchemeBuilder      runtime.SchemeBuilder
	localSchemeBuilder = &SchemeBuilder

	// AddToScheme adds this group to a scheme.
	AddToScheme = localSchemeBuilder.AddToScheme
)

func init() {
	// We only register manually written functions here. The registration of the
	// generated functions takes place in the generated files. The separation
	// makes the code compile even when the generated files are missing.
	localSchemeBuilder.Register(addKnownTypes)
}

// Adds the list of known types to the given scheme.
func addKnownTypes(scheme *runtime.Scheme) error {
	metav1.AddToGroupVersion(scheme, SchemeGroupVersion)
	return nil
}

// Resource takes an unqualified resource and returns a Group qualified GroupResource
func Resource(resource string) schema.GroupResource {
	return SchemeGroupVersion.WithResource(resource).GroupResource()
}

// RegisterDynamicTypes registers types dynamically based on config
func RegisterDynamicTypes(scheme *runtime.Scheme, cfg *config.ResourceConfig) error {
	for _, res := range cfg.Resources {
		kind := res.Application.Kind

		gvk := SchemeGroupVersion.WithKind(kind)
		scheme.AddKnownTypeWithName(gvk, &Application{})
		scheme.AddKnownTypeWithName(gvk.GroupVersion().WithKind(kind+"List"), &ApplicationList{})

		gvkInternal := schema.GroupVersion{Group: GroupName, Version: runtime.APIVersionInternal}.WithKind(kind)
		scheme.AddKnownTypeWithName(gvkInternal, &Application{})
		scheme.AddKnownTypeWithName(gvkInternal.GroupVersion().WithKind(kind+"List"), &ApplicationList{})

		klog.V(1).Infof("Registered kind: %s\n", kind)
		RegisteredGVKs = append(RegisteredGVKs, gvk)
	}

	return nil
}
