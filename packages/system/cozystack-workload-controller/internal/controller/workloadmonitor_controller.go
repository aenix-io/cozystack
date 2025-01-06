package controller

import (
	"context"
	"time"

	apierrors "k8s.io/apimachinery/pkg/api/errors"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apimachinery/pkg/types"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/handler"
	"sigs.k8s.io/controller-runtime/pkg/log"
	"sigs.k8s.io/controller-runtime/pkg/reconcile"

	cozyv1alpha1 "github.com/aenix-io/cozystack/api/v1alpha1"
)

// WorkloadMonitorReconciler reconciles a WorkloadMonitor object
type WorkloadMonitorReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

// +kubebuilder:rbac:groups=cozystack.io,resources=workloadmonitors,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=cozystack.io,resources=workloadmonitors/status,verbs=get;update;patch
// +kubebuilder:rbac:groups=cozystack.io,resources=workloadmonitors/finalizers,verbs=update
// +kubebuilder:rbac:groups=cozystack.io,resources=workloads,verbs=get;list;watch

func (r *WorkloadMonitorReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	logger := log.FromContext(ctx)

	// Get WorkloadMonitor instance
	monitor := &cozyv1alpha1.WorkloadMonitor{}
	err := r.Get(ctx, req.NamespacedName, monitor)
	if err != nil {
		if apierrors.IsNotFound(err) {
			return ctrl.Result{}, nil
		}
		logger.Error(err, "Unable to fetch WorkloadMonitor")
		return ctrl.Result{}, err
	}

	// List all workloads matching the selector
	workloadList := &cozyv1alpha1.WorkloadList{}
	listOpts := []client.ListOption{
		client.InNamespace(monitor.Namespace),
		client.MatchingLabels(monitor.Spec.Selector),
	}

	if err := r.List(ctx, workloadList, listOpts...); err != nil {
		logger.Error(err, "Unable to list workloads")
		return ctrl.Result{}, err
	}

	logger.Info("Found workloads",
		"count", len(workloadList.Items),
		"selector", monitor.Spec.Selector,
		"namespace", monitor.Namespace)

	// Count available and total workloads
	var availableReplicas, observedReplicas int32
	for _, workload := range workloadList.Items {
		observedReplicas++
		if workload.Status.Operational {
			availableReplicas++
		}
		logger.Info("Processing workload",
			"name", workload.Name,
			"operational", workload.Status.Operational,
			"kind", workload.Status.Kind,
			"type", workload.Status.Type)
	}

	// Create patch object for status update
	patch := client.MergeFrom(monitor.DeepCopy())

	// Update status fields
	monitor.Status.AvailableReplicas = availableReplicas
	monitor.Status.ObservedReplicas = observedReplicas

	// Check if operational based on the criteria
	monitor.Status.Operational = true

	// Get target replicas (use spec.replicas if set, otherwise use observedReplicas)
	targetReplicas := observedReplicas
	if monitor.Spec.Replicas != nil {
		targetReplicas = *monitor.Spec.Replicas
	}

	if monitor.Spec.MinReplicas != nil && availableReplicas < *monitor.Spec.MinReplicas {
		monitor.Status.Operational = false
		logger.Info("Available replicas below minimum",
			"available", availableReplicas,
			"minimum", *monitor.Spec.MinReplicas)
	}

	logger.Info("Updating status",
		"availableReplicas", monitor.Status.AvailableReplicas,
		"observedReplicas", monitor.Status.ObservedReplicas,
		"targetReplicas", targetReplicas,
		"operational", monitor.Status.Operational,
		"minReplicas", monitor.Spec.MinReplicas)

	// Update status using patch
	if err := r.Status().Patch(ctx, monitor, patch); err != nil {
		logger.Error(err, "Unable to update WorkloadMonitor status")
		return ctrl.Result{}, err
	}

	// Requeue periodically to ensure status stays up to date
	return ctrl.Result{RequeueAfter: 30 * time.Second}, nil
}

func (r *WorkloadMonitorReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&cozyv1alpha1.WorkloadMonitor{}).
		Watches(
			&cozyv1alpha1.Workload{},
			handler.EnqueueRequestsFromMapFunc(func(ctx context.Context, obj client.Object) []reconcile.Request {
				workload := obj.(*cozyv1alpha1.Workload)

				// List all WorkloadMonitors
				monitorList := &cozyv1alpha1.WorkloadMonitorList{}
				if err := r.List(ctx, monitorList, client.InNamespace(workload.Namespace)); err != nil {
					return nil
				}

				var requests []reconcile.Request
				// Check each monitor's selector
				for _, monitor := range monitorList.Items {
					matches := true
					for k, v := range monitor.Spec.Selector {
						if workload.Labels[k] != v {
							matches = false
							break
						}
					}
					if matches {
						requests = append(requests, reconcile.Request{
							NamespacedName: types.NamespacedName{
								Name:      monitor.Name,
								Namespace: monitor.Namespace,
							},
						})
					}
				}
				return requests
			})).
		Complete(r)
}
