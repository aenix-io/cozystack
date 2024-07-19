# etcd-operator

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity |
| etcdOperator.args[0] | string | `"--health-probe-bind-address=:8081"` |  |
| etcdOperator.args[1] | string | `"--metrics-bind-address=127.0.0.1:8080"` |  |
| etcdOperator.args[2] | string | `"--leader-elect"` |  |
| etcdOperator.envVars | object | `{}` | Empty environment variables section |
| etcdOperator.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| etcdOperator.image.repository | string | `"ghcr.io/aenix-io/etcd-operator"` | Image repository |
| etcdOperator.image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| etcdOperator.livenessProbe.httpGet.path | string | `"/healthz"` | Healthcheck liveness probe path |
| etcdOperator.livenessProbe.httpGet.port | int | `8081` | Healthcheck port |
| etcdOperator.livenessProbe.initialDelaySeconds | int | `15` | ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes |
| etcdOperator.livenessProbe.periodSeconds | int | `20` | ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes |
| etcdOperator.readinessProbe.httpGet.path | string | `"/readyz"` | Healthcheck readiness probe path |
| etcdOperator.readinessProbe.httpGet.port | int | `8081` | Healthcheck port |
| etcdOperator.readinessProbe.initialDelaySeconds | int | `5` | ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes |
| etcdOperator.readinessProbe.periodSeconds | int | `10` | ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes |
| etcdOperator.resources | object | `{"limits":{"cpu":"500m","memory":"128Mi"},"requests":{"cpu":"100m","memory":"64Mi"}}` | ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| etcdOperator.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}` | ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| etcdOperator.service.port | int | `9443` | Service port |
| etcdOperator.service.type | string | `"ClusterIP"` | Service type |
| fullnameOverride | string | `""` | Override a full name of helm release |
| imagePullSecrets | list | `[]` |  |
| kubeRbacProxy.args[0] | string | `"--secure-listen-address=0.0.0.0:8443"` |  |
| kubeRbacProxy.args[1] | string | `"--upstream=http://127.0.0.1:8080/"` |  |
| kubeRbacProxy.args[2] | string | `"--logtostderr=true"` |  |
| kubeRbacProxy.args[3] | string | `"--v=0"` |  |
| kubeRbacProxy.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| kubeRbacProxy.image.repository | string | `"gcr.io/kubebuilder/kube-rbac-proxy"` | Image repository |
| kubeRbacProxy.image.tag | string | `"v0.16.0"` | Version of image |
| kubeRbacProxy.livenessProbe | object | `{}` | https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| kubeRbacProxy.readinessProbe | object | `{}` | https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/ |
| kubeRbacProxy.resources | object | `{"limits":{"cpu":"250m","memory":"128Mi"},"requests":{"cpu":"100m","memory":"64Mi"}}` | ref: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/ |
| kubeRbacProxy.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}` | ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| kubeRbacProxy.service.port | int | `8443` | Service port |
| kubeRbacProxy.service.type | string | `"ClusterIP"` | Service type |
| kubernetesClusterDomain | string | `"cluster.local"` | Kubernetes cluster domain prefix |
| nameOverride | string | `""` | Override a name of helm release |
| nodeSelector | object | `{}` | ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/ |
| podAnnotations | object | `{}` | ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| podLabels | object | `{}` | ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/ |
| podSecurityContext | object | `{}` | ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ |
| replicaCount | int | `1` | Count of pod replicas |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| tolerations | list | `[]` | ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/ |

