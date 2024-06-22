# flux-operator

![Version: 0.6.0](https://img.shields.io/badge/Version-0.6.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.6.0](https://img.shields.io/badge/AppVersion-v0.6.0-informational?style=flat-square)

The [Flux Operator](https://github.com/controlplaneio-fluxcd) provides a declarative API
for the installation and upgrade of CNCF [Flux](https://fluxcd.io) and the
ControlPlane [enterprise distribution](https://control-plane.io/enterprise-for-flux-cd/).

The operator automates the patching for hotfixes and CVEs affecting the Flux controllers container images
and enables the configuration of multi-tenancy lockdown on Kubernetes and OpenShift clusters.

## Prerequisites

- Kubernetes 1.22+
- Helm 3.8+

## Installing the Chart

To install the operator in the `flux-system` namespace:

```console
helm install flux-operator oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
  --namespace flux-system \
  --create-namespace \
  --wait
```

To deploy the Flux controllers and to configure automated updates,
see the Flux Operator [documentation](https://fluxcd.control-plane.io/operator/).

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/os","operator":"In","values":["linux"]}]}]}}}` | Pod affinity and anti-affinity settings. |
| commonAnnotations | object | `{}` | Common annotations to add to all deployed objects including pods. |
| commonLabels | object | `{}` | Common labels to add to all deployed objects including pods. |
| extraEnvs | list | `[]` | Container extra environment variables. |
| fullnameOverride | string | `""` |  |
| hostNetwork | bool | `false` | If `true`, the container ports (`8080` and `8081`) are exposed on the host network. |
| image | object | `{"pullSecrets":[],"repository":"ghcr.io/controlplaneio-fluxcd/flux-operator","tag":""}` | Container image settings. The image tag defaults to the chart appVersion. |
| installCRDs | bool | `true` | Install and upgrade the custom resource definitions. |
| livenessProbe | object | `{"httpGet":{"path":"/healthz","port":8081},"initialDelaySeconds":15,"periodSeconds":20}` | Container liveness probe settings. |
| marketplace | object | `{"account":"","license":"","type":""}` | Marketplace settings. |
| nameOverride | string | `""` |  |
| podSecurityContext | object | `{}` | Pod security context settings. |
| priorityClassName | string | `""` | Pod priority class name. Recommended value is system-cluster-critical. |
| readinessProbe | object | `{"httpGet":{"path":"/readyz","port":8081},"initialDelaySeconds":5,"periodSeconds":10}` | Container readiness probe settings. |
| resources | object | `{"limits":{"cpu":"1000m","memory":"1Gi"},"requests":{"cpu":"100m","memory":"64Mi"}}` | Container resources requests and limits settings. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Container security context settings. The default is compliant with the pod security restricted profile. |
| serviceAccount | object | `{"automount":true,"create":true,"name":""}` | Pod service account settings. The name of the service account defaults to the release name. |
| tolerations | list | `[]` | Pod tolerations settings. |

## Source Code

* <https://github.com/controlplaneio-fluxcd/flux-operator>
* <https://github.com/controlplaneio-fluxcd/charts>
