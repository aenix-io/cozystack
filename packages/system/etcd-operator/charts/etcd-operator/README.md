# etcd-operator

![Version: 0.0.0](https://img.shields.io/badge/Version-0.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.0.0](https://img.shields.io/badge/AppVersion-v0.0.0-informational?style=flat-square)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| etcdOperator.args[0] | string | `"--health-probe-bind-address=:8081"` |  |
| etcdOperator.args[1] | string | `"--metrics-bind-address=127.0.0.1:8080"` |  |
| etcdOperator.args[2] | string | `"--leader-elect"` |  |
| etcdOperator.envVars | object | `{}` |  |
| etcdOperator.image.pullPolicy | string | `"IfNotPresent"` |  |
| etcdOperator.image.repository | string | `"ghcr.io/aenix-io/etcd-operator"` |  |
| etcdOperator.image.tag | string | `""` |  |
| etcdOperator.livenessProbe.httpGet.path | string | `"/healthz"` |  |
| etcdOperator.livenessProbe.httpGet.port | int | `8081` |  |
| etcdOperator.livenessProbe.initialDelaySeconds | int | `15` |  |
| etcdOperator.livenessProbe.periodSeconds | int | `20` |  |
| etcdOperator.readinessProbe.httpGet.path | string | `"/readyz"` |  |
| etcdOperator.readinessProbe.httpGet.port | int | `8081` |  |
| etcdOperator.readinessProbe.initialDelaySeconds | int | `5` |  |
| etcdOperator.readinessProbe.periodSeconds | int | `10` |  |
| etcdOperator.resources.limits.cpu | string | `"500m"` |  |
| etcdOperator.resources.limits.memory | string | `"128Mi"` |  |
| etcdOperator.resources.requests.cpu | string | `"100m"` |  |
| etcdOperator.resources.requests.memory | string | `"64Mi"` |  |
| etcdOperator.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| etcdOperator.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| etcdOperator.service.port | int | `9443` |  |
| etcdOperator.service.type | string | `"ClusterIP"` |  |
| fullnameOverride | string | `""` |  |
| imagePullSecrets | list | `[]` |  |
| kubeRbacProxy.args[0] | string | `"--secure-listen-address=0.0.0.0:8443"` |  |
| kubeRbacProxy.args[1] | string | `"--upstream=http://127.0.0.1:8080/"` |  |
| kubeRbacProxy.args[2] | string | `"--logtostderr=true"` |  |
| kubeRbacProxy.args[3] | string | `"--v=0"` |  |
| kubeRbacProxy.image.pullPolicy | string | `"IfNotPresent"` |  |
| kubeRbacProxy.image.repository | string | `"gcr.io/kubebuilder/kube-rbac-proxy"` |  |
| kubeRbacProxy.image.tag | string | `"v0.16.0"` |  |
| kubeRbacProxy.livenessProbe | object | `{}` |  |
| kubeRbacProxy.readinessProbe | object | `{}` |  |
| kubeRbacProxy.resources.limits.cpu | string | `"500m"` |  |
| kubeRbacProxy.resources.limits.memory | string | `"128Mi"` |  |
| kubeRbacProxy.resources.requests.cpu | string | `"100m"` |  |
| kubeRbacProxy.resources.requests.memory | string | `"64Mi"` |  |
| kubeRbacProxy.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| kubeRbacProxy.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| kubeRbacProxy.service.port | int | `8443` |  |
| kubeRbacProxy.service.type | string | `"ClusterIP"` |  |
| kubernetesClusterDomain | string | `"cluster.local"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| tolerations | list | `[]` |  |

