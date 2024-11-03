package application

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"strings"
	"sync"
	"time"

	helmv2 "github.com/fluxcd/helm-controller/api/v2"
	metainternalversion "k8s.io/apimachinery/pkg/apis/meta/internalversion"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/apis/meta/v1/unstructured"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/apimachinery/pkg/util/duration"
	"k8s.io/apimachinery/pkg/watch"
	"k8s.io/apiserver/pkg/endpoints/request"
	"k8s.io/apiserver/pkg/registry/rest"
	"k8s.io/apiserver/pkg/storage"
	"k8s.io/client-go/dynamic"

	appsv1alpha1 "github.com/aenix.io/cozystack/pkg/apis/apps/v1alpha1"
	"github.com/aenix.io/cozystack/pkg/config"
)

// Ensure REST implements necessary interfaces
var (
	_ rest.Getter          = &REST{}
	_ rest.Lister          = &REST{}
	_ rest.Updater         = &REST{}
	_ rest.Creater         = &REST{}
	_ rest.GracefulDeleter = &REST{}
	_ rest.Watcher         = &REST{}
	_ rest.Patcher         = &REST{}
)

// Define constants for label and annotation prefixes
const (
	LabelPrefix      = "apps.cozystack.io-"
	AnnotationPrefix = "apps.cozystack.io-"
)

// Define the GroupVersionResource for HelmRelease
var helmReleaseGVR = schema.GroupVersionResource{
	Group:    "helm.toolkit.fluxcd.io",
	Version:  "v2",
	Resource: "helmreleases",
}

// REST implements the RESTStorage interface for Application resources
type REST struct {
	dynamicClient dynamic.Interface
	gvr           schema.GroupVersionResource
	gvk           schema.GroupVersionKind
	kindName      string
	releaseConfig config.ReleaseConfig
}

// NewREST creates a new REST storage for Application with specific configuration
func NewREST(dynamicClient dynamic.Interface, config *config.Resource) *REST {
	return &REST{
		dynamicClient: dynamicClient,
		gvr: schema.GroupVersionResource{
			Group:    appsv1alpha1.GroupName,
			Version:  "v1alpha1",
			Resource: config.Application.Plural,
		},
		gvk: schema.GroupVersion{
			Group:   appsv1alpha1.GroupName,
			Version: "v1alpha1",
		}.WithKind(config.Application.Kind),
		kindName:      config.Application.Kind,
		releaseConfig: config.Release,
	}
}

// NamespaceScoped indicates whether the resource is namespaced
func (r *REST) NamespaceScoped() bool {
	return true
}

// GetSingularName returns the singular name of the resource
func (r *REST) GetSingularName() string {
	return r.gvr.Resource
}

// Create handles the creation of a new Application by converting it to a HelmRelease
func (r *REST) Create(ctx context.Context, obj runtime.Object, createValidation rest.ValidateObjectFunc, options *metav1.CreateOptions) (runtime.Object, error) {
	// Assert the object is of type Application
	app, ok := obj.(*appsv1alpha1.Application)
	if !ok {
		return nil, fmt.Errorf("expected Application object, got %T", obj)
	}

	// Convert Application to HelmRelease
	helmRelease, err := r.ConvertApplicationToHelmRelease(app)
	if err != nil {
		return nil, fmt.Errorf("conversion error: %v", err)
	}

	// Merge system labels (from config) directly
	helmRelease.Labels = mergeMaps(r.releaseConfig.Labels, helmRelease.Labels)
	// Merge user labels with prefix
	helmRelease.Labels = mergeMaps(helmRelease.Labels, addPrefixedMap(app.Labels, LabelPrefix))
	// Note: Annotations from config are not handled as r.releaseConfig.Annotations is undefined

	// Convert HelmRelease to unstructured format
	unstructuredHR, err := runtime.DefaultUnstructuredConverter.ToUnstructured(helmRelease)
	if err != nil {
		return nil, fmt.Errorf("failed to convert HelmRelease to unstructured: %v", err)
	}

	log.Printf("Creating HelmRelease %s in namespace %s", helmRelease.Name, app.Namespace)

	// Create HelmRelease in Kubernetes
	createdHR, err := r.dynamicClient.Resource(helmReleaseGVR).Namespace(app.Namespace).Create(ctx, &unstructured.Unstructured{Object: unstructuredHR}, *options)
	if err != nil {
		log.Printf("Failed to create HelmRelease %s: %v", helmRelease.Name, err)
		return nil, fmt.Errorf("failed to create HelmRelease: %v", err)
	}

	// Convert the created HelmRelease back to Application
	convertedApp, err := r.ConvertHelmReleaseToApplication(createdHR)
	if err != nil {
		log.Printf("Conversion error from HelmRelease to Application for resource %s: %v", createdHR.GetName(), err)
		return nil, fmt.Errorf("conversion error: %v", err)
	}

	log.Printf("Successfully created and converted HelmRelease %s to Application", createdHR.GetName())

	// Convert Application to unstructured format
	unstructuredApp, err := runtime.DefaultUnstructuredConverter.ToUnstructured(&convertedApp)
	if err != nil {
		log.Printf("Failed to convert Application to unstructured for resource %s: %v", convertedApp.GetName(), err)
		return nil, fmt.Errorf("failed to convert Application to unstructured: %v", err)
	}

	log.Printf("Successfully retrieved and converted resource %s of type %s to unstructured", convertedApp.GetName(), r.gvr.Resource)
	return &unstructured.Unstructured{Object: unstructuredApp}, nil
}

// Get retrieves an Application by converting the corresponding HelmRelease
func (r *REST) Get(ctx context.Context, name string, options *metav1.GetOptions) (runtime.Object, error) {
	namespace, err := r.getNamespace(ctx)
	if err != nil {
		return nil, err
	}

	log.Printf("Attempting to retrieve resource %s of type %s in namespace %s", name, r.gvr.Resource, namespace)

	// Get the corresponding HelmRelease using the new prefix
	helmReleaseName := r.releaseConfig.Prefix + name
	hr, err := r.dynamicClient.Resource(helmReleaseGVR).Namespace(namespace).Get(ctx, helmReleaseName, *options)
	if err != nil {
		log.Printf("Error retrieving HelmRelease for resource %s: %v", name, err)
		return nil, err
	}

	// Convert HelmRelease to Application
	convertedApp, err := r.ConvertHelmReleaseToApplication(hr)
	if err != nil {
		log.Printf("Conversion error from HelmRelease to Application for resource %s: %v", name, err)
		return nil, fmt.Errorf("conversion error: %v", err)
	}

	// Convert Application to unstructured format
	unstructuredApp, err := runtime.DefaultUnstructuredConverter.ToUnstructured(&convertedApp)
	if err != nil {
		log.Printf("Failed to convert Application to unstructured for resource %s: %v", name, err)
		return nil, fmt.Errorf("failed to convert Application to unstructured: %v", err)
	}

	log.Printf("Successfully retrieved and converted resource %s of kind %s to unstructured", name, r.gvr.Resource)
	return &unstructured.Unstructured{Object: unstructuredApp}, nil
}

// List retrieves a list of Applications by converting HelmReleases
func (r *REST) List(ctx context.Context, options *metainternalversion.ListOptions) (runtime.Object, error) {
	namespace, err := r.getNamespace(ctx)
	if err != nil {
		return nil, err
	}

	log.Printf("Attempting to list all HelmReleases in namespace %s", namespace)

	metaOptions := metav1.ListOptions{
		LabelSelector: options.LabelSelector.String(),
		FieldSelector: options.FieldSelector.String(),
	}

	// List HelmReleases based on selectors
	hrList, err := r.dynamicClient.Resource(helmReleaseGVR).Namespace(namespace).List(ctx, metaOptions)
	if err != nil {
		log.Printf("Error listing HelmReleases: %v", err)
		return nil, err
	}

	// Initialize an empty ApplicationList
	appList := &appsv1alpha1.ApplicationList{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "apps.cozystack.io/v1alpha1",
			Kind:       "ApplicationList",
		},
		ListMeta: metav1.ListMeta{
			ResourceVersion: hrList.GetResourceVersion(),
		},
		Items: []appsv1alpha1.Application{},
	}

	// Iterate over HelmReleases and convert to Applications
	for _, hr := range hrList.Items {
		if !r.shouldIncludeHelmRelease(&hr) {
			continue
		}

		app, err := r.ConvertHelmReleaseToApplication(&hr)
		if err != nil {
			log.Printf("Error converting HelmRelease %s to Application: %v", hr.GetName(), err)
			continue
		}

		// Remove the prefix from the Application name
		app.Name = strings.TrimPrefix(app.Name, r.releaseConfig.Prefix)
		appList.Items = append(appList.Items, app)
	}

	log.Printf("Successfully listed %d Application resources in namespace %s", len(appList.Items), namespace)
	return appList, nil
}

// Update updates an existing Application by converting it to a HelmRelease
func (r *REST) Update(ctx context.Context, name string, objInfo rest.UpdatedObjectInfo, createValidation rest.ValidateObjectFunc, updateValidation rest.ValidateObjectUpdateFunc, forceAllowCreate bool, options *metav1.UpdateOptions) (runtime.Object, bool, error) {
	// Retrieve the existing Application
	oldObj, err := r.Get(ctx, name, &metav1.GetOptions{})
	if err != nil {
		if storage.IsNotFound(err) {
			if !forceAllowCreate {
				return nil, false, err
			}
			// If not found and force allow create, create a new one
			obj, err := objInfo.UpdatedObject(ctx, nil)
			if err != nil {
				return nil, false, err
			}
			createdObj, err := r.Create(ctx, obj, createValidation, &metav1.CreateOptions{})
			if err != nil {
				return nil, false, err
			}
			return createdObj, true, nil
		}
		return nil, false, err
	}

	// Update the Application object
	newObj, err := objInfo.UpdatedObject(ctx, oldObj)
	if err != nil {
		return nil, false, err
	}

	// Validate the update if a validation function is provided
	if updateValidation != nil {
		if err := updateValidation(ctx, newObj, oldObj); err != nil {
			return nil, false, err
		}
	}

	// Assert the new object is of type Application
	app, ok := newObj.(*appsv1alpha1.Application)
	if !ok {
		return nil, false, fmt.Errorf("expected Application object, got %T", newObj)
	}

	// Convert Application to HelmRelease
	helmRelease, err := r.ConvertApplicationToHelmRelease(app)
	if err != nil {
		return nil, false, fmt.Errorf("conversion error: %v", err)
	}

	// Merge system labels (from config) directly
	helmRelease.Labels = mergeMaps(r.releaseConfig.Labels, helmRelease.Labels)
	// Merge user labels with prefix
	helmRelease.Labels = mergeMaps(helmRelease.Labels, addPrefixedMap(app.Labels, LabelPrefix))
	// Note: Annotations from config are not handled as r.releaseConfig.Annotations is undefined

	// Convert HelmRelease to unstructured format
	unstructuredHR, err := runtime.DefaultUnstructuredConverter.ToUnstructured(helmRelease)
	if err != nil {
		return nil, false, fmt.Errorf("failed to convert HelmRelease to unstructured: %v", err)
	}

	metadata, found, err := unstructured.NestedMap(unstructuredHR, "metadata")
	if err != nil || !found {
		log.Printf("Failed to retrieve metadata from HelmRelease: %v, found: %v", err, found)
		return nil, false, fmt.Errorf("failed to retrieve metadata from HelmRelease: %v", err)
	}
	log.Printf("HelmRelease Metadata: %+v", metadata)

	log.Printf("Updating HelmRelease %s in namespace %s", helmRelease.Name, helmRelease.Namespace)

	// Update the HelmRelease in Kubernetes
	resultHR, err := r.dynamicClient.Resource(helmReleaseGVR).Namespace(helmRelease.Namespace).Update(ctx, &unstructured.Unstructured{Object: unstructuredHR}, metav1.UpdateOptions{})
	if err != nil {
		log.Printf("Failed to update HelmRelease %s: %v", helmRelease.Name, err)
		return nil, false, fmt.Errorf("failed to update HelmRelease: %v", err)
	}

	// Convert the updated HelmRelease back to Application
	convertedApp, err := r.ConvertHelmReleaseToApplication(resultHR)
	if err != nil {
		log.Printf("Conversion error from HelmRelease to Application for resource %s: %v", resultHR.GetName(), err)
		return nil, false, fmt.Errorf("conversion error: %v", err)
	}

	log.Printf("Successfully updated and converted HelmRelease %s to Application", resultHR.GetName())

	// Convert Application to unstructured format
	unstructuredApp, err := runtime.DefaultUnstructuredConverter.ToUnstructured(&convertedApp)
	if err != nil {
		log.Printf("Failed to convert Application to unstructured for resource %s: %v", convertedApp.GetName(), err)
		return nil, false, fmt.Errorf("failed to convert Application to unstructured: %v", err)
	}

	log.Printf("Returning patched Application object: %+v", unstructuredApp)

	return &unstructured.Unstructured{Object: unstructuredApp}, false, nil
}

// Delete removes an Application by deleting the corresponding HelmRelease
func (r *REST) Delete(ctx context.Context, name string, deleteValidation rest.ValidateObjectFunc, options *metav1.DeleteOptions) (runtime.Object, bool, error) {
	namespace, err := r.getNamespace(ctx)
	if err != nil {
		return nil, false, err
	}

	log.Printf("Deleting HelmRelease %s in namespace %s", name, namespace)

	// Construct HelmRelease name with new prefix
	helmReleaseName := r.releaseConfig.Prefix + name

	// Delete the HelmRelease corresponding to the Application
	err = r.dynamicClient.Resource(helmReleaseGVR).Namespace(namespace).Delete(ctx, helmReleaseName, *options)
	if err != nil {
		log.Printf("Failed to delete HelmRelease %s: %v", helmReleaseName, err)
		return nil, false, err
	}

	log.Printf("Successfully deleted HelmRelease %s", helmReleaseName)
	return nil, true, nil
}

// Watch sets up a watch on HelmReleases, filters them, and converts events to Applications
func (r *REST) Watch(ctx context.Context, options *metainternalversion.ListOptions) (watch.Interface, error) {
	namespace, err := r.getNamespace(ctx)
	if err != nil {
		return nil, err
	}

	log.Printf("Setting up watch for HelmReleases in namespace %s with options: %v", namespace, options)

	listOptions := metav1.ListOptions{
		LabelSelector: buildLabelSelector(r.releaseConfig.Labels),
		FieldSelector: options.FieldSelector.String(),
	}

	// List HelmReleases to obtain the current resource version
	list, err := r.dynamicClient.Resource(helmReleaseGVR).Namespace(namespace).List(ctx, listOptions)
	if err != nil {
		log.Printf("Error listing HelmReleases for watch: %v", err)
		return nil, err
	}

	resourceVersion := list.GetResourceVersion()
	log.Printf("Obtained resourceVersion %s for watch", resourceVersion)

	// Set up watch options with the obtained resource version
	metaOptions := metav1.ListOptions{
		LabelSelector:   buildLabelSelector(r.releaseConfig.Labels),
		FieldSelector:   options.FieldSelector.String(),
		Watch:           true,
		ResourceVersion: resourceVersion,
	}

	// Start watching HelmReleases
	helmWatcher, err := r.dynamicClient.Resource(helmReleaseGVR).Namespace(namespace).Watch(ctx, metaOptions)
	if err != nil {
		log.Printf("Error setting up watch for HelmReleases: %v", err)
		return nil, err
	}

	// Create a custom watcher to handle event filtering and conversion
	customW := &customWatcher{
		resultChan: make(chan watch.Event),
		stopChan:   make(chan struct{}),
	}

	go func() {
		defer close(customW.resultChan)
		for {
			select {
			case event, ok := <-helmWatcher.ResultChan():
				if !ok {
					return
				}

				// Check if the HelmRelease event is relevant based on filtering criteria
				matches, err := r.isRelevantHelmRelease(&event)
				if err != nil {
					log.Printf("Error filtering HelmRelease event: %v", err)
					continue
				}

				if !matches {
					continue
				}

				// Convert HelmRelease to Application
				app, err := r.ConvertHelmReleaseToApplication(event.Object.(*unstructured.Unstructured))
				if err != nil {
					log.Printf("Error converting HelmRelease to Application: %v", err)
					continue
				}

				// Convert Application to unstructured format
				unstructuredApp, err := runtime.DefaultUnstructuredConverter.ToUnstructured(&app)
				if err != nil {
					log.Printf("Failed to convert Application to unstructured: %v", err)
					continue
				}

				// Create a new watch event with the Application object
				appEvent := watch.Event{
					Type:   event.Type,
					Object: &unstructured.Unstructured{Object: unstructuredApp},
				}

				select {
				case customW.resultChan <- appEvent:
				case <-customW.stopChan:
					return
				case <-ctx.Done():
					return
				}

			case <-customW.stopChan:
				return
			case <-ctx.Done():
				return
			}
		}
	}()

	log.Printf("Custom watch established successfully")
	return customW, nil
}

// customWatcher wraps the original watcher and filters/converts events
type customWatcher struct {
	resultChan chan watch.Event
	stopChan   chan struct{}
	stopOnce   sync.Once
}

// Stop terminates the watch
func (cw *customWatcher) Stop() {
	cw.stopOnce.Do(func() {
		close(cw.stopChan)
	})
}

// ResultChan returns the event channel
func (cw *customWatcher) ResultChan() <-chan watch.Event {
	return cw.resultChan
}

// isRelevantHelmRelease checks if the HelmRelease meets the specified criteria
func (r *REST) isRelevantHelmRelease(event *watch.Event) (bool, error) {
	if event.Object == nil {
		return false, nil
	}

	hr, ok := event.Object.(*unstructured.Unstructured)
	if !ok {
		return false, fmt.Errorf("expected Unstructured object, got %T", event.Object)
	}

	// Filter by Chart Name
	chartName, found, err := unstructured.NestedString(hr.Object, "spec", "chart", "spec", "chart")
	if err != nil || !found {
		log.Printf("HelmRelease %s missing spec.chart.spec.chart field: %v", hr.GetName(), err)
		return false, nil
	}
	if chartName != r.releaseConfig.Chart.Name {
		return false, nil
	}

	// Filter by SourceRefConfig and Prefix
	return r.matchesSourceRefAndPrefix(hr), nil
}

// shouldIncludeHelmRelease determines if a HelmRelease should be included based on filtering criteria
func (r *REST) shouldIncludeHelmRelease(hr *unstructured.Unstructured) bool {
	// Filter by Chart Name
	chartName, found, err := unstructured.NestedString(hr.Object, "spec", "chart", "spec", "chart")
	if err != nil || !found {
		log.Printf("HelmRelease %s missing spec.chart.spec.chart field: %v", hr.GetName(), err)
		return false
	}
	if chartName != r.releaseConfig.Chart.Name {
		log.Printf("HelmRelease %s chart name %s does not match expected %s", hr.GetName(), chartName, r.releaseConfig.Chart.Name)
		return false
	}

	// Filter by SourceRefConfig and Prefix
	return r.matchesSourceRefAndPrefix(hr)
}

// matchesSourceRefAndPrefix checks both SourceRefConfig and Prefix criteria
func (r *REST) matchesSourceRefAndPrefix(hr *unstructured.Unstructured) bool {
	// Extract SourceRef fields
	sourceRefKind, found, err := unstructured.NestedString(hr.Object, "spec", "chart", "spec", "sourceRef", "kind")
	if err != nil || !found {
		log.Printf("HelmRelease %s missing spec.chart.spec.sourceRef.kind field: %v", hr.GetName(), err)
		return false
	}
	sourceRefName, found, err := unstructured.NestedString(hr.Object, "spec", "chart", "spec", "sourceRef", "name")
	if err != nil || !found {
		log.Printf("HelmRelease %s missing spec.chart.spec.sourceRef.name field: %v", hr.GetName(), err)
		return false
	}
	sourceRefNamespace, found, err := unstructured.NestedString(hr.Object, "spec", "chart", "spec", "sourceRef", "namespace")
	if err != nil || !found {
		log.Printf("HelmRelease %s missing spec.chart.spec.sourceRef.namespace field: %v", hr.GetName(), err)
		return false
	}

	// Check if SourceRef matches the configuration
	if sourceRefKind != r.releaseConfig.Chart.SourceRef.Kind ||
		sourceRefName != r.releaseConfig.Chart.SourceRef.Name ||
		sourceRefNamespace != r.releaseConfig.Chart.SourceRef.Namespace {
		log.Printf("HelmRelease %s sourceRef does not match expected values", hr.GetName())
		return false
	}

	// Additional filtering by Prefix
	name := hr.GetName()
	if !strings.HasPrefix(name, r.releaseConfig.Prefix) {
		log.Printf("HelmRelease %s does not have the expected prefix %s", name, r.releaseConfig.Prefix)
		return false
	}

	return true
}

// getNamespace extracts the namespace from the context
func (r *REST) getNamespace(ctx context.Context) (string, error) {
	namespace, ok := request.NamespaceFrom(ctx)
	if !ok {
		return "", fmt.Errorf("namespace not found in context")
	}
	return namespace, nil
}

// buildLabelSelector constructs a label selector string from a map of labels
func buildLabelSelector(labels map[string]string) string {
	var selectors []string
	for k, v := range labels {
		selectors = append(selectors, fmt.Sprintf("%s=%s", k, v))
	}
	return strings.Join(selectors, ",")
}

// mergeMaps combines two maps of labels or annotations
func mergeMaps(a, b map[string]string) map[string]string {
	if a == nil && b == nil {
		return nil
	}
	if a == nil {
		return b
	}
	if b == nil {
		return a
	}
	merged := make(map[string]string, len(a)+len(b))
	for k, v := range a {
		merged[k] = v
	}
	for k, v := range b {
		merged[k] = v
	}
	return merged
}

// addPrefixedMap adds the predefined prefix to the keys of a map
func addPrefixedMap(original map[string]string, prefix string) map[string]string {
	if original == nil {
		return nil
	}
	processed := make(map[string]string, len(original))
	for k, v := range original {
		processed[prefix+k] = v
	}
	return processed
}

// filterPrefixedMap filters a map by the predefined prefix and removes the prefix from the keys
func filterPrefixedMap(original map[string]string, prefix string) map[string]string {
	if original == nil {
		return nil
	}
	processed := make(map[string]string)
	for k, v := range original {
		if strings.HasPrefix(k, prefix) {
			newKey := strings.TrimPrefix(k, prefix)
			processed[newKey] = v
		}
	}
	return processed
}

// ConvertHelmReleaseToApplication converts a HelmRelease to an Application
func (r *REST) ConvertHelmReleaseToApplication(hr *unstructured.Unstructured) (appsv1alpha1.Application, error) {
	log.Printf("Converting HelmRelease to Application for resource %s", hr.GetName())

	var helmRelease helmv2.HelmRelease
	// Convert unstructured to HelmRelease struct
	err := runtime.DefaultUnstructuredConverter.FromUnstructured(hr.Object, &helmRelease)
	if err != nil {
		log.Printf("Error converting from unstructured to HelmRelease: %v", err)
		return appsv1alpha1.Application{}, err
	}

	// Convert HelmRelease struct to Application struct
	app, err := r.convertHelmReleaseToApplication(&helmRelease)
	if err != nil {
		log.Printf("Error converting from HelmRelease to Application: %v", err)
		return appsv1alpha1.Application{}, err
	}

	log.Printf("Successfully converted HelmRelease %s to Application", hr.GetName())
	return app, nil
}

// ConvertApplicationToHelmRelease converts an Application to a HelmRelease
func (r *REST) ConvertApplicationToHelmRelease(app *appsv1alpha1.Application) (*helmv2.HelmRelease, error) {
	return r.convertApplicationToHelmRelease(app)
}

// convertHelmReleaseToApplication implements the actual conversion logic
func (r *REST) convertHelmReleaseToApplication(hr *helmv2.HelmRelease) (appsv1alpha1.Application, error) {
	app := appsv1alpha1.Application{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "apps.cozystack.io/v1alpha1",
			Kind:       r.kindName,
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:              strings.TrimPrefix(hr.Name, r.releaseConfig.Prefix),
			Namespace:         hr.Namespace,
			UID:               hr.GetUID(),
			ResourceVersion:   hr.GetResourceVersion(),
			CreationTimestamp: hr.CreationTimestamp,
			DeletionTimestamp: hr.DeletionTimestamp,
			Labels:            filterPrefixedMap(hr.Labels, LabelPrefix),
			Annotations:       filterPrefixedMap(hr.Annotations, AnnotationPrefix),
		},
		Spec: hr.Spec.Values,
		Status: appsv1alpha1.ApplicationStatus{
			Version: hr.Status.LastAttemptedRevision,
		},
	}

	var conditions []metav1.Condition
	for _, hrCondition := range hr.GetConditions() {
		if hrCondition.Type == "Ready" || hrCondition.Type == "Released" {
			conditions = append(conditions, metav1.Condition{
				LastTransitionTime: hrCondition.LastTransitionTime,
				Reason:             hrCondition.Reason,
				Message:            hrCondition.Message,
				Status:             hrCondition.Status,
				Type:               hrCondition.Type,
			})
		}
	}
	app.SetConditions(conditions)
	return app, nil
}

// convertApplicationToHelmRelease implements the actual conversion logic
func (r *REST) convertApplicationToHelmRelease(app *appsv1alpha1.Application) (*helmv2.HelmRelease, error) {
	helmRelease := &helmv2.HelmRelease{
		TypeMeta: metav1.TypeMeta{
			APIVersion: "helm.toolkit.fluxcd.io/v2",
			Kind:       "HelmRelease",
		},
		ObjectMeta: metav1.ObjectMeta{
			Name:            r.releaseConfig.Prefix + app.Name,
			Namespace:       app.Namespace,
			Labels:          addPrefixedMap(app.Labels, LabelPrefix),
			Annotations:     addPrefixedMap(app.Annotations, AnnotationPrefix),
			ResourceVersion: app.ObjectMeta.ResourceVersion,
			UID:             app.ObjectMeta.UID,
		},
		Spec: helmv2.HelmReleaseSpec{
			Chart: &helmv2.HelmChartTemplate{
				Spec: helmv2.HelmChartTemplateSpec{
					Chart:             r.releaseConfig.Chart.Name,
					Version:           app.AppVersion,
					ReconcileStrategy: "Revision",
					SourceRef: helmv2.CrossNamespaceObjectReference{
						Kind:      r.releaseConfig.Chart.SourceRef.Kind,
						Name:      r.releaseConfig.Chart.SourceRef.Name,
						Namespace: r.releaseConfig.Chart.SourceRef.Namespace,
					},
				},
			},
			Values: app.Spec,
		},
	}

	return helmRelease, nil
}

// ConvertToTable implements the TableConvertor interface for displaying resources in a table format
func (r *REST) ConvertToTable(ctx context.Context, object runtime.Object, tableOptions runtime.Object) (*metav1.Table, error) {
	log.Printf("ConvertToTable: received object of type %T", object)

	var table metav1.Table

	switch obj := object.(type) {
	case *appsv1alpha1.ApplicationList:
		table = r.buildTableFromApplications(obj.Items)
	case *appsv1alpha1.Application:
		table = r.buildTableFromApplication(*obj)
	case *unstructured.Unstructured:
		var app appsv1alpha1.Application
		err := runtime.DefaultUnstructuredConverter.FromUnstructured(obj.UnstructuredContent(), &app)
		if err != nil {
			log.Printf("Failed to convert Unstructured to Application: %v", err)
			return nil, fmt.Errorf("failed to convert Unstructured to Application: %v", err)
		}
		table = r.buildTableFromApplication(app)
	default:
		resource := schema.GroupResource{}
		if info, ok := request.RequestInfoFrom(ctx); ok {
			resource = schema.GroupResource{Group: info.APIGroup, Resource: info.Resource}
		}
		return nil, errNotAcceptable{
			resource: resource,
			message:  "object does not implement the Object interfaces",
		}
	}

	// Handle table options
	if opt, ok := tableOptions.(*metav1.TableOptions); ok && opt != nil && opt.NoHeaders {
		table.ColumnDefinitions = nil
	}

	table.TypeMeta = metav1.TypeMeta{
		APIVersion: "meta.k8s.io/v1",
		Kind:       "Table",
	}

	log.Printf("ConvertToTable: returning table with %d rows", len(table.Rows))

	return &table, nil
}

// buildTableFromApplications constructs a table from a list of Applications
func (r *REST) buildTableFromApplications(apps []appsv1alpha1.Application) metav1.Table {
	table := metav1.Table{
		ColumnDefinitions: []metav1.TableColumnDefinition{
			{Name: "NAME", Type: "string", Description: "Name of the Application", Priority: 0},
			{Name: "READY", Type: "string", Description: "Ready status of the Application", Priority: 0},
			{Name: "AGE", Type: "string", Description: "Age of the Application", Priority: 0},
			{Name: "VERSION", Type: "string", Description: "Version of the Application", Priority: 0},
		},
		Rows: make([]metav1.TableRow, 0, len(apps)),
		ListMeta: metav1.ListMeta{
			ResourceVersion: "", // To be set by the caller if needed
		},
	}
	now := time.Now()

	for _, app := range apps {
		row := metav1.TableRow{
			Cells:  []interface{}{app.GetName(), getReadyStatus(app.Status.Conditions), computeAge(app.GetCreationTimestamp().Time, now), getVersion(app.Status.Version)},
			Object: runtime.RawExtension{Object: &app},
		}
		table.Rows = append(table.Rows, row)
	}

	table.ListMeta = metav1.ListMeta{
		ResourceVersion: "", // To be set by the caller if needed
	}

	return table
}

// buildTableFromApplication constructs a table from a single Application
func (r *REST) buildTableFromApplication(app appsv1alpha1.Application) metav1.Table {
	table := metav1.Table{
		ColumnDefinitions: []metav1.TableColumnDefinition{
			{Name: "NAME", Type: "string", Description: "Name of the Application", Priority: 0},
			{Name: "READY", Type: "string", Description: "Ready status of the Application", Priority: 0},
			{Name: "AGE", Type: "string", Description: "Age of the Application", Priority: 0},
			{Name: "VERSION", Type: "string", Description: "Version of the Application", Priority: 0},
		},
		Rows: []metav1.TableRow{},
		ListMeta: metav1.ListMeta{
			ResourceVersion: "", // To be set by the caller if needed
		},
	}
	now := time.Now()

	row := metav1.TableRow{
		Cells:  []interface{}{app.GetName(), getReadyStatus(app.Status.Conditions), computeAge(app.GetCreationTimestamp().Time, now), getVersion(app.Status.Version)},
		Object: runtime.RawExtension{Object: &app},
	}
	table.Rows = append(table.Rows, row)

	table.ListMeta = metav1.ListMeta{
		ResourceVersion: "", // To be set by the caller if needed
	}

	return table
}

// getVersion returns the application version or a placeholder if unknown
func getVersion(version string) string {
	if version == "" {
		return "<unknown>"
	}
	return version
}

// computeAge calculates the age of the object based on CreationTimestamp and current time
func computeAge(creationTime, currentTime time.Time) string {
	ageDuration := currentTime.Sub(creationTime)
	return duration.HumanDuration(ageDuration)
}

// getReadyStatus returns the ready status based on conditions
func getReadyStatus(conditions []metav1.Condition) string {
	for _, condition := range conditions {
		if condition.Type == "Ready" {
			switch condition.Status {
			case metav1.ConditionTrue:
				return "True"
			case metav1.ConditionFalse:
				return "False"
			default:
				return "Unknown"
			}
		}
	}
	return "Unknown"
}

// Destroy releases resources associated with REST
func (r *REST) Destroy() {
	// No additional actions needed to release resources.
}

// New creates a new instance of Application
func (r *REST) New() runtime.Object {
	return &appsv1alpha1.Application{}
}

// NewList returns an empty list of Application objects
func (r *REST) NewList() runtime.Object {
	return &appsv1alpha1.ApplicationList{}
}

// Kind returns the resource kind used for API discovery
func (r *REST) Kind() string {
	return r.gvk.Kind
}

// GroupVersionKind returns the GroupVersionKind for REST
func (r *REST) GroupVersionKind(schema.GroupVersion) schema.GroupVersionKind {
	return r.gvk
}

// errNotAcceptable indicates that the resource does not support conversion to Table
type errNotAcceptable struct {
	resource schema.GroupResource
	message  string
}

func (e errNotAcceptable) Error() string {
	return e.message
}

func (e errNotAcceptable) Status() metav1.Status {
	return metav1.Status{
		Status:  metav1.StatusFailure,
		Code:    http.StatusNotAcceptable,
		Reason:  metav1.StatusReason("NotAcceptable"),
		Message: e.Error(),
	}
}
