package controller

import (
	"context"
	"encoding/json"

	apierrors "k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/types"
	"k8s.io/utils/pointer"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/handler"
	"sigs.k8s.io/controller-runtime/pkg/log"
	"sigs.k8s.io/controller-runtime/pkg/reconcile"

	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"

	cozyv1alpha1 "github.com/aenix-io/cozystack/api/v1alpha1"
	"sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
)

// WorkloadMonitorReconciler reconciles a WorkloadMonitor object
type WorkloadMonitorReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

// +kubebuilder:rbac:groups=cozystack.io,resources=workloadmonitors,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=cozystack.io,resources=workloadmonitors/status,verbs=get;update;patch
// +kubebuilder:rbac:groups=cozystack.io,resources=workloads,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=cozystack.io,resources=workloads/status,verbs=get;update;patch
// +kubebuilder:rbac:groups=core,resources=pods,verbs=get;list;watch

// isPodReady checks if the Pod is in the Ready condition.
func (r *WorkloadMonitorReconciler) isPodReady(pod *corev1.Pod) bool {
	for _, c := range pod.Status.Conditions {
		if c.Type == corev1.PodReady && c.Status == corev1.ConditionTrue {
			return true
		}
	}
	return false
}

// reconcilePodForMonitor creates or updates a Workload object for the given Pod and WorkloadMonitor.
func (r *WorkloadMonitorReconciler) reconcilePodForMonitor(
	ctx context.Context,
	monitor *cozyv1alpha1.WorkloadMonitor,
	pod corev1.Pod,
) error {
	logger := log.FromContext(ctx)

	// Combine both init containers and normal containers to sum resources properly
	combinedContainers := append(pod.Spec.InitContainers, pod.Spec.Containers...)

	// totalResources will store the sum of all container resource limits
	totalResources := make(map[string]resource.Quantity)

	// Iterate over all containers to aggregate their Limits
	for _, container := range combinedContainers {
		for name, qty := range container.Resources.Limits {
			if existing, exists := totalResources[name.String()]; exists {
				existing.Add(qty)
				totalResources[name.String()] = existing
			} else {
				totalResources[name.String()] = qty.DeepCopy()
			}
		}
	}

	// If annotation "workload.cozystack.io/resources" is present, parse and merge
	if resourcesStr, ok := pod.Annotations["workload.cozystack.io/resources"]; ok {
		annRes := map[string]string{}
		if err := json.Unmarshal([]byte(resourcesStr), &annRes); err != nil {
			logger.Error(err, "Failed to parse resources annotation", "pod", pod.Name)
			// We do not return an error here to keep reconciling other Pods
		} else {
			for k, v := range annRes {
				parsed, err := resource.ParseQuantity(v)
				if err != nil {
					logger.Error(err, "Failed to parse resource quantity from annotation", "key", k, "value", v)
					continue
				}
				totalResources[k] = parsed
			}
		}
	}

	// Prepare the Workload object
	workload := &cozyv1alpha1.Workload{
		ObjectMeta: metav1.ObjectMeta{
			Name:      pod.Name, // or any logic to ensure uniqueness
			Namespace: pod.Namespace,
		},
	}

	// CreateOrUpdate the Workload owned by this WorkloadMonitor
	_, err := ctrl.CreateOrUpdate(ctx, r.Client, workload, func() error {
		// Set this WorkloadMonitor as owner for garbage collection
		if err := controllerutil.SetControllerReference(monitor, workload, r.Scheme); err != nil {
			return err
		}

		// Copy labels from the Pod if needed
		workload.Labels = pod.Labels

		// Fill Workload status fields:
		// - Kind and Type come from the WorkloadMonitor spec
		workload.Status.Kind = monitor.Spec.Kind
		workload.Status.Type = monitor.Spec.Type

		// Convert the resource map to the Workload's .Status.Resources
		workload.Status.Resources = totalResources
		workload.Status.Operational = r.isPodReady(&pod)

		return nil
	})
	if err != nil {
		logger.Error(err, "Failed to CreateOrUpdate Workload", "workload", workload.Name)
		return err
	}

	return nil
}

// Reconcile is the main reconcile loop.
// 1. It reconciles WorkloadMonitor objects themselves (create/update/delete).
// 2. It also reconciles Pod events mapped to WorkloadMonitor via label selector.
func (r *WorkloadMonitorReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	logger := log.FromContext(ctx)

	// Fetch the WorkloadMonitor object if it exists
	monitor := &cozyv1alpha1.WorkloadMonitor{}
	err := r.Get(ctx, req.NamespacedName, monitor)
	if err != nil {
		// If the resource is not found, it may be a Pod event (mapFunc).
		if apierrors.IsNotFound(err) {
			return ctrl.Result{}, nil
		}
		logger.Error(err, "Unable to fetch WorkloadMonitor")
		return ctrl.Result{}, err
	}

	// List Pods that match the WorkloadMonitor's selector
	podList := &corev1.PodList{}
	if err := r.List(
		ctx,
		podList,
		client.InNamespace(monitor.Namespace),
		client.MatchingLabels(monitor.Spec.Selector),
	); err != nil {
		logger.Error(err, "Unable to list Pods for WorkloadMonitor", "monitor", monitor.Name)
		return ctrl.Result{}, err
	}

	var observedReplicas, availableReplicas int32

	// For each matching Pod, reconcile the corresponding Workload
	for _, pod := range podList.Items {
		observedReplicas++
		if err := r.reconcilePodForMonitor(ctx, monitor, pod); err != nil {
			logger.Error(err, "Failed to reconcile Workload for Pod", "pod", pod.Name)
			continue
		}
		if r.isPodReady(&pod) {
			availableReplicas++
		}
	}

	// Update WorkloadMonitor status based on observed pods
	monitor.Status.ObservedReplicas = observedReplicas
	monitor.Status.AvailableReplicas = availableReplicas

	// Default to operational = true, but check MinReplicas if set
	monitor.Status.Operational = pointer.Bool(true)
	if monitor.Spec.MinReplicas != nil && availableReplicas < *monitor.Spec.MinReplicas {
		monitor.Status.Operational = pointer.Bool(false)
	}

	// Update the WorkloadMonitor status in the cluster
	if err := r.Status().Update(ctx, monitor); err != nil {
		logger.Error(err, "Unable to update WorkloadMonitor status", "monitor", monitor.Name)
		return ctrl.Result{}, err
	}

	// Return without requeue if we want purely event-driven reconciliations
	return ctrl.Result{}, nil
}

// SetupWithManager registers our controller with the Manager and sets up watches.
func (r *WorkloadMonitorReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		// Watch WorkloadMonitor objects
		For(&cozyv1alpha1.WorkloadMonitor{}).
		// Also watch Pod objects and map them back to WorkloadMonitor if labels match
		Watches(
			&corev1.Pod{},
			handler.EnqueueRequestsFromMapFunc(func(ctx context.Context, obj client.Object) []reconcile.Request {
				pod, ok := obj.(*corev1.Pod)
				if !ok {
					return nil
				}

				var monitorList cozyv1alpha1.WorkloadMonitorList
				// List all WorkloadMonitors in the same namespace
				if err := r.List(ctx, &monitorList, client.InNamespace(pod.Namespace)); err != nil {
					return nil
				}

				// Match each monitor's selector with the Pod's labels
				var requests []reconcile.Request
				for _, m := range monitorList.Items {
					matches := true
					for k, v := range m.Spec.Selector {
						if podVal, exists := pod.Labels[k]; !exists || podVal != v {
							matches = false
							break
						}
					}
					if matches {
						requests = append(requests, reconcile.Request{
							NamespacedName: types.NamespacedName{
								Namespace: m.Namespace,
								Name:      m.Name,
							},
						})
					}
				}
				return requests
			}),
		).
		// Watch for changes to Workload objects we create (owned by WorkloadMonitor)
		Owns(&cozyv1alpha1.Workload{}).
		Complete(r)
}
