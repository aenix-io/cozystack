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

// isPodReady checks if the Pod is in Ready condition.
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

	// Collect resources from Pod's container limits
	totalResources := map[string]resource.Quantity{}
	for _, container := range pod.Spec.Containers {
		for name, qty := range container.Resources.Limits {
			if existing, exists := totalResources[name.String()]; exists {
				existing.Add(qty)
				totalResources[name.String()] = existing
			} else {
				totalResources[name.String()] = qty
			}
		}
	}

	// If annotation "workload.cozystack.io/resources" is present, merge it
	if resourcesStr, ok := pod.Annotations["workload.cozystack.io/resources"]; ok {
		annRes := map[string]string{}
		if err := json.Unmarshal([]byte(resourcesStr), &annRes); err != nil {
			logger.Error(err, "Failed to parse resources annotation", "pod", pod.Name)
			// we do not return an error here to keep reconciling other Pods
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

	// Create or Update the Workload
	_, err := ctrl.CreateOrUpdate(ctx, r.Client, workload, func() error {
		// Set WorkloadMonitor as the owner, so Workload is deleted automatically if monitor is removed.
		if err := controllerutil.SetControllerReference(monitor, workload, r.Scheme); err != nil {
			// If there's an owner reference conflict, handle it appropriately
			return err
		}

		// Copy labels from the Pod if needed (or just set your own)
		workload.Labels = pod.Labels

		// Fill Workload status fields:
		// Kind and Type come from the WorkloadMonitor spec per the new requirements
		workload.Status.Kind = monitor.Spec.Kind // example: "redis"
		workload.Status.Type = monitor.Spec.Type // example: "sentinel"

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

// Reconcile handles two scenarios:
// 1) Reconciling WorkloadMonitor objects themselves (create/update/delete).
// 2) Reconciling Pod events, which we map to relevant WorkloadMonitor(s).
func (r *WorkloadMonitorReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	logger := log.FromContext(ctx)

	// Try to fetch the WorkloadMonitor. If it exists, we proceed with normal logic.
	// If it's not found, it might be a Pod event -> we handle that via watch mapping below.
	monitor := &cozyv1alpha1.WorkloadMonitor{}
	err := r.Get(ctx, req.NamespacedName, monitor)
	if err != nil {
		// If the resource is not found, it might be a Pod reconciling attempt (mapFunc).
		if apierrors.IsNotFound(err) {
			// nothing to do if the WorkloadMonitor doesn't exist
			return ctrl.Result{}, nil
		}
		logger.Error(err, "Unable to fetch WorkloadMonitor")
		return ctrl.Result{}, err
	}

	// 1. List Pods that match this monitor's Selector
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

	// 2. For each matching Pod, create or update a Workload
	for _, pod := range podList.Items {
		observedReplicas++
		if err := r.reconcilePodForMonitor(ctx, monitor, pod); err != nil {
			logger.Error(err, "Failed to reconcile Workload for Pod", "pod", pod.Name)
			// continue or return depending on your logic
			continue
		}
		if r.isPodReady(&pod) {
			availableReplicas++
		}
	}

	// 3. Update WorkloadMonitor status
	monitor.Status.ObservedReplicas = observedReplicas
	monitor.Status.AvailableReplicas = availableReplicas
	monitor.Status.Operational = pointer.Bool(true)

	if monitor.Spec.MinReplicas != nil && availableReplicas < *monitor.Spec.MinReplicas {
		monitor.Status.Operational = pointer.Bool(false)
	}

	// Use MergeFrom to properly patch only status changes
	// patch := client.MergeFrom(monitor.DeepCopy())
	// if err := r.Status().Patch(ctx, monitor, patch); err != nil {
	// 	logger.Error(err, "Unable to update WorkloadMonitor status", "monitor", monitor.Name)
	// 	return ctrl.Result{}, err
	// }
	if err := r.Status().Update(ctx, monitor); err != nil {
		logger.Error(err, "Unable to update WorkloadMonitor status", "monitor", monitor.Name)
		return ctrl.Result{}, err
	}

	// If no periodic resync is desired, return without requeue.
	return ctrl.Result{}, nil
}

// SetupWithManager sets up the controller with the Manager.
func (r *WorkloadMonitorReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		// Watch for changes to WorkloadMonitor objects
		For(&cozyv1alpha1.WorkloadMonitor{}).
		// Also watch for Pod events, and map them to the relevant WorkloadMonitor(s)
		Watches(
			&corev1.Pod{},
			handler.EnqueueRequestsFromMapFunc(func(ctx context.Context, obj client.Object) []reconcile.Request {
				pod, ok := obj.(*corev1.Pod)
				if !ok {
					return nil
				}

				// Find all WorkloadMonitors in the same namespace
				var monitorList cozyv1alpha1.WorkloadMonitorList
				if err := r.List(ctx, &monitorList, client.InNamespace(pod.Namespace)); err != nil {
					// if we can't list, we can't do any mapping
					return nil
				}

				var requests []reconcile.Request
				// For each monitor, check if the Pod labels satisfy the monitor's selector
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
		// Watch for changes to Workload objects we create. If needed, you can enqueue the parent monitor again:
		Owns(&cozyv1alpha1.Workload{}).
		Complete(r)
}
