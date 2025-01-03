/*
Copyright 2025.

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

package controller

import (
	"context"
	"encoding/json"

	cozyv1alpha1 "github.com/aenix-io/cozystack/api/v1alpha1"
	corev1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/api/resource"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/runtime"
	ctrl "sigs.k8s.io/controller-runtime"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/controller/controllerutil"
	"sigs.k8s.io/controller-runtime/pkg/handler"
	"sigs.k8s.io/controller-runtime/pkg/log"
)

type WorkloadReconciler struct {
	client.Client
	Scheme *runtime.Scheme
}

// +kubebuilder:rbac:groups=core,resources=pods,verbs=get;list;watch
// +kubebuilder:rbac:groups=cozystack.io,resources=workloads,verbs=get;list;watch;create;update;patch;delete
// +kubebuilder:rbac:groups=cozystack.io,resources=workloads/status,verbs=get;update;patch

func (r *WorkloadReconciler) reconcilePod(ctx context.Context, pod *corev1.Pod) (ctrl.Result, error) {
	logger := log.FromContext(ctx)

	kind, hasKind := pod.Labels["workload.cozystack.io/kind"]
	if !hasKind {
		return ctrl.Result{}, nil
	}

	workloadType, hasType := pod.Labels["workload.cozystack.io/type"]
	if !hasType {
		workloadType = kind
	}

	resources := map[string]resource.Quantity{}
	for _, container := range pod.Spec.Containers {
		for resourceName, quantity := range container.Resources.Limits {
			if existing, exists := resources[resourceName.String()]; exists {
				existing.Add(quantity)
				resources[resourceName.String()] = existing
			} else {
				resources[resourceName.String()] = quantity
			}
		}
	}

	if resourcesStr, ok := pod.Annotations["workload.cozystack.io/resources"]; ok {
		var annotationResources map[string]string
		if err := json.Unmarshal([]byte(resourcesStr), &annotationResources); err != nil {
			logger.Error(err, "Failed to parse resources annotation")
			return ctrl.Result{}, err
		}

		for name, value := range annotationResources {
			quantity, err := resource.ParseQuantity(value)
			if err != nil {
				logger.Error(err, "Failed to parse resource quantity", "resource", name, "value", value)
				continue
			}
			resources[name] = quantity
		}
	}

	workload := &cozyv1alpha1.Workload{
		ObjectMeta: metav1.ObjectMeta{
			Name:      pod.Name,
			Namespace: pod.Namespace,
		},
	}

	op, err := ctrl.CreateOrUpdate(ctx, r.Client, workload,
		func() error {
			if err := controllerutil.SetOwnerReference(pod, workload, r.Scheme); err != nil {
				return err
			}

			workload.Status.Kind = kind
			workload.Status.Type = workloadType
			workload.Status.Resources = resources

			return nil
		})

	if err != nil {
		logger.Error(err, "Failed to create/update Workload")
		return ctrl.Result{}, err
	}

	logger.Info("Reconciled Workload", "operation", op)
	return ctrl.Result{}, nil
}

func (r *WorkloadReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	logger := log.FromContext(ctx)

	pod := &corev1.Pod{}
	err := r.Get(ctx, req.NamespacedName, pod)
	if client.IgnoreNotFound(err) != nil {
		return ctrl.Result{}, err
	}

	// If the pod is found and has the necessary labels, process it
	if err == nil && pod.Labels["workload.cozystack.io/kind"] != "" {
		return r.reconcilePod(ctx, pod)
	}

	// If the pod is not found or has no labels, check the workload
	workload := &cozyv1alpha1.Workload{}
	if err := r.Get(ctx, req.NamespacedName, workload); err == nil {
		if ownerRef := metav1.GetControllerOf(workload); ownerRef != nil {
			pod := &corev1.Pod{}
			if err := r.Get(ctx, client.ObjectKey{Name: ownerRef.Name, Namespace: workload.Namespace}, pod); err == nil {
				return r.reconcilePod(ctx, pod)
			}
			logger.Info("Owner Pod not found, deleting Workload")
			return ctrl.Result{}, r.Delete(ctx, workload)
		}
	}

	return ctrl.Result{}, nil
}

func (r *WorkloadReconciler) SetupWithManager(mgr ctrl.Manager) error {
	return ctrl.NewControllerManagedBy(mgr).
		For(&corev1.Pod{}).
		Owns(&cozyv1alpha1.Workload{}).
		Watches(
			&cozyv1alpha1.Workload{},
			&handler.EnqueueRequestForObject{},
		).
		Complete(r)
}
