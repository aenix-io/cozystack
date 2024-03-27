# flux2

![Version: 2.12.4](https://img.shields.io/badge/Version-2.12.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 2.2.3](https://img.shields.io/badge/AppVersion-2.2.3-informational?style=flat-square)

A Helm chart for flux2

This helm chart is maintained and released by the fluxcd-community on a best effort basis.

## Source Code

* <https://github.com/fluxcd-community/helm-charts>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cli.affinity | object | `{}` |  |
| cli.annotations | object | `{}` |  |
| cli.image | string | `"ghcr.io/fluxcd/flux-cli"` |  |
| cli.nodeSelector | object | `{}` |  |
| cli.serviceAccount.automount | bool | `true` |  |
| cli.tag | string | `"v2.2.3"` |  |
| cli.tolerations | list | `[]` |  |
| clusterDomain | string | `"cluster.local"` |  |
| crds.annotations | object | `{}` | Add annotations to all CRD resources, e.g. "helm.sh/resource-policy": keep |
| extraObjects | list | `[]` | Array of extra K8s manifests to deploy |
| helmController.affinity | object | `{}` |  |
| helmController.annotations."prometheus.io/port" | string | `"8080"` |  |
| helmController.annotations."prometheus.io/scrape" | string | `"true"` |  |
| helmController.container.additionalArgs | list | `[]` |  |
| helmController.create | bool | `true` |  |
| helmController.extraEnv | list | `[]` |  |
| helmController.image | string | `"ghcr.io/fluxcd/helm-controller"` |  |
| helmController.imagePullPolicy | string | `""` |  |
| helmController.labels | object | `{}` |  |
| helmController.nodeSelector | object | `{}` |  |
| helmController.priorityClassName | string | `""` |  |
| helmController.resources.limits | object | `{}` |  |
| helmController.resources.requests.cpu | string | `"100m"` |  |
| helmController.resources.requests.memory | string | `"64Mi"` |  |
| helmController.serviceAccount.annotations | object | `{}` |  |
| helmController.serviceAccount.automount | bool | `true` |  |
| helmController.serviceAccount.create | bool | `true` |  |
| helmController.tag | string | `"v0.37.4"` |  |
| helmController.tolerations | list | `[]` |  |
| imageAutomationController.affinity | object | `{}` |  |
| imageAutomationController.annotations."prometheus.io/port" | string | `"8080"` |  |
| imageAutomationController.annotations."prometheus.io/scrape" | string | `"true"` |  |
| imageAutomationController.container.additionalArgs | list | `[]` |  |
| imageAutomationController.create | bool | `true` |  |
| imageAutomationController.extraEnv | list | `[]` |  |
| imageAutomationController.image | string | `"ghcr.io/fluxcd/image-automation-controller"` |  |
| imageAutomationController.imagePullPolicy | string | `""` |  |
| imageAutomationController.labels | object | `{}` |  |
| imageAutomationController.nodeSelector | object | `{}` |  |
| imageAutomationController.priorityClassName | string | `""` |  |
| imageAutomationController.resources.limits | object | `{}` |  |
| imageAutomationController.resources.requests.cpu | string | `"100m"` |  |
| imageAutomationController.resources.requests.memory | string | `"64Mi"` |  |
| imageAutomationController.serviceAccount.annotations | object | `{}` |  |
| imageAutomationController.serviceAccount.automount | bool | `true` |  |
| imageAutomationController.serviceAccount.create | bool | `true` |  |
| imageAutomationController.tag | string | `"v0.37.1"` |  |
| imageAutomationController.tolerations | list | `[]` |  |
| imagePullSecrets | list | `[]` | contents of pod imagePullSecret in form 'name=[secretName]'; applied to all controllers |
| imageReflectionController.affinity | object | `{}` |  |
| imageReflectionController.annotations."prometheus.io/port" | string | `"8080"` |  |
| imageReflectionController.annotations."prometheus.io/scrape" | string | `"true"` |  |
| imageReflectionController.container.additionalArgs | list | `[]` |  |
| imageReflectionController.create | bool | `true` |  |
| imageReflectionController.extraEnv | list | `[]` |  |
| imageReflectionController.image | string | `"ghcr.io/fluxcd/image-reflector-controller"` |  |
| imageReflectionController.imagePullPolicy | string | `""` |  |
| imageReflectionController.labels | object | `{}` |  |
| imageReflectionController.nodeSelector | object | `{}` |  |
| imageReflectionController.priorityClassName | string | `""` |  |
| imageReflectionController.resources.limits | object | `{}` |  |
| imageReflectionController.resources.requests.cpu | string | `"100m"` |  |
| imageReflectionController.resources.requests.memory | string | `"64Mi"` |  |
| imageReflectionController.serviceAccount.annotations | object | `{}` |  |
| imageReflectionController.serviceAccount.automount | bool | `true` |  |
| imageReflectionController.serviceAccount.create | bool | `true` |  |
| imageReflectionController.tag | string | `"v0.31.2"` |  |
| imageReflectionController.tolerations | list | `[]` |  |
| installCRDs | bool | `true` |  |
| kustomizeController.affinity | object | `{}` |  |
| kustomizeController.annotations."prometheus.io/port" | string | `"8080"` |  |
| kustomizeController.annotations."prometheus.io/scrape" | string | `"true"` |  |
| kustomizeController.container.additionalArgs | list | `[]` |  |
| kustomizeController.create | bool | `true` |  |
| kustomizeController.envFrom | object | `{"map":{"name":""},"secret":{"name":""}}` | Defines envFrom using a configmap and/or secret. |
| kustomizeController.extraEnv | list | `[]` |  |
| kustomizeController.extraSecretMounts | list | `[]` | Defines additional mounts with secrets. Secrets must be manually created in the namespace or with kustomizeController.secret |
| kustomizeController.image | string | `"ghcr.io/fluxcd/kustomize-controller"` |  |
| kustomizeController.imagePullPolicy | string | `""` |  |
| kustomizeController.labels | object | `{}` |  |
| kustomizeController.nodeSelector | object | `{}` |  |
| kustomizeController.priorityClassName | string | `""` |  |
| kustomizeController.resources.limits | object | `{}` |  |
| kustomizeController.resources.requests.cpu | string | `"100m"` |  |
| kustomizeController.resources.requests.memory | string | `"64Mi"` |  |
| kustomizeController.secret.create | bool | `false` | Create a secret to use it with extraSecretMounts. Defaults to false. |
| kustomizeController.secret.data | object | `{}` |  |
| kustomizeController.secret.name | string | `""` |  |
| kustomizeController.serviceAccount.annotations | object | `{}` |  |
| kustomizeController.serviceAccount.automount | bool | `true` |  |
| kustomizeController.serviceAccount.create | bool | `true` |  |
| kustomizeController.tag | string | `"v1.2.2"` |  |
| kustomizeController.tolerations | list | `[]` |  |
| logLevel | string | `"info"` |  |
| multitenancy.defaultServiceAccount | string | `"default"` | All Kustomizations and HelmReleases which don’t have spec.serviceAccountName specified, will use the default account from the tenant’s namespace. Tenants have to specify a service account in their Flux resources to be able to deploy workloads in their namespaces as the default account has no permissions. |
| multitenancy.enabled | bool | `false` | Implement the patches for Multi-tenancy lockdown. See https://fluxcd.io/docs/installation/#multi-tenancy-lockdown |
| multitenancy.privileged | bool | `true` | Both kustomize-controller and helm-controller service accounts run privileged with cluster-admin ClusterRoleBinding. Disable if you want to run them with a minimum set of permissions. |
| notificationController.affinity | object | `{}` |  |
| notificationController.annotations."prometheus.io/port" | string | `"8080"` |  |
| notificationController.annotations."prometheus.io/scrape" | string | `"true"` |  |
| notificationController.container.additionalArgs | list | `[]` |  |
| notificationController.create | bool | `true` |  |
| notificationController.extraEnv | list | `[]` |  |
| notificationController.image | string | `"ghcr.io/fluxcd/notification-controller"` |  |
| notificationController.imagePullPolicy | string | `""` |  |
| notificationController.labels | object | `{}` |  |
| notificationController.nodeSelector | object | `{}` |  |
| notificationController.priorityClassName | string | `""` |  |
| notificationController.resources.limits | object | `{}` |  |
| notificationController.resources.requests.cpu | string | `"100m"` |  |
| notificationController.resources.requests.memory | string | `"64Mi"` |  |
| notificationController.service.annotations | object | `{}` |  |
| notificationController.service.labels | object | `{}` |  |
| notificationController.serviceAccount.annotations | object | `{}` |  |
| notificationController.serviceAccount.automount | bool | `true` |  |
| notificationController.serviceAccount.create | bool | `true` |  |
| notificationController.tag | string | `"v1.2.4"` |  |
| notificationController.tolerations | list | `[]` |  |
| notificationController.webhookReceiver.ingress.annotations | object | `{}` |  |
| notificationController.webhookReceiver.ingress.create | bool | `false` |  |
| notificationController.webhookReceiver.ingress.hosts[0].host | string | `"flux-webhook.example.com"` |  |
| notificationController.webhookReceiver.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| notificationController.webhookReceiver.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| notificationController.webhookReceiver.ingress.labels | object | `{}` |  |
| notificationController.webhookReceiver.ingress.tls | list | `[]` |  |
| notificationController.webhookReceiver.service.annotations | object | `{}` |  |
| notificationController.webhookReceiver.service.labels | object | `{}` |  |
| policies.create | bool | `true` |  |
| prometheus.podMonitor.create | bool | `false` | Enables podMonitor endpoint |
| prometheus.podMonitor.podMetricsEndpoints[0].port | string | `"http-prom"` |  |
| prometheus.podMonitor.podMetricsEndpoints[0].relabelings[0].action | string | `"keep"` |  |
| prometheus.podMonitor.podMetricsEndpoints[0].relabelings[0].regex | string | `"Running"` |  |
| prometheus.podMonitor.podMetricsEndpoints[0].relabelings[0].sourceLabels[0] | string | `"__meta_kubernetes_pod_phase"` |  |
| rbac.annotations | object | `{}` | Add annotations to all RBAC resources, e.g. "helm.sh/resource-policy": keep |
| rbac.create | bool | `true` |  |
| rbac.createAggregation | bool | `true` | Grant the Kubernetes view, edit and admin roles access to Flux custom resources |
| sourceController.affinity | object | `{}` |  |
| sourceController.annotations."prometheus.io/port" | string | `"8080"` |  |
| sourceController.annotations."prometheus.io/scrape" | string | `"true"` |  |
| sourceController.container.additionalArgs | list | `[]` |  |
| sourceController.create | bool | `true` |  |
| sourceController.extraEnv | list | `[]` |  |
| sourceController.image | string | `"ghcr.io/fluxcd/source-controller"` |  |
| sourceController.imagePullPolicy | string | `""` |  |
| sourceController.labels | object | `{}` |  |
| sourceController.nodeSelector | object | `{}` |  |
| sourceController.priorityClassName | string | `""` |  |
| sourceController.resources.limits | object | `{}` |  |
| sourceController.resources.requests.cpu | string | `"100m"` |  |
| sourceController.resources.requests.memory | string | `"64Mi"` |  |
| sourceController.service.annotations | object | `{}` |  |
| sourceController.service.labels | object | `{}` |  |
| sourceController.serviceAccount.annotations | object | `{}` |  |
| sourceController.serviceAccount.automount | bool | `true` |  |
| sourceController.serviceAccount.create | bool | `true` |  |
| sourceController.tag | string | `"v1.2.4"` |  |
| sourceController.tolerations | list | `[]` |  |
| watchAllNamespaces | bool | `true` |  |
