---
title: "Helm installation"
linkTitle: "Helm installation"
---

# grafana-operator

[grafana-operator](https://github.com/grafana/grafana-operator) for Kubernetes to manage Grafana instances and grafana resources.

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v5.6.0](https://img.shields.io/badge/AppVersion-v5.6.0-informational?style=flat-square)

## Installation

This is a OCI helm chart, helm started support OCI in version 3.8.0.

```shell
helm upgrade -i grafana-operator oci://ghcr.io/grafana/helm-charts/grafana-operator --version v5.6.0
```

Sadly helm OCI charts currently don't support searching for available versions of a helm [oci registry](https://github.com/helm/helm/issues/11000).

## Development

For general and helm specific development instructions please read the [CONTRIBUTING.md](../../../CONTRIBUTING.md)

## Out of scope

The chart won't support any configuration of grafana instances or similar. It's only meant to be used to install the grafana-operator.
Deployments of grafana instances using the CRs is supposed to be done outside of the chart.

Currently the plan is not to support networkpolicy. The operators support os diverse configuration that you have to support all options.
It's easier to just manage this configuration outside of the operator.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalLabels | object | `{}` | additional labels to add to all resources |
| affinity | object | `{}` | pod affinity |
| env | list | `[]` | Additional environment variables |
| fullnameOverride | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` | The image pull policy to use in grafana operator container |
| image.repository | string | `"ghcr.io/grafana/grafana-operator"` | grafana operator image repository |
| image.tag | string | `""` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | image pull secrets |
| leaderElect | bool | `false` | If you want to run multiple replicas of the grafana-operator, this is not recommended. |
| metricsService.metricsPort | int | `9090` | metrics service port |
| metricsService.type | string | `"ClusterIP"` | metrics service type |
| nameOverride | string | `""` |  |
| namespaceScope | bool | `false` | If the operator should run in namespace-scope or not, if true the operator will only be able to manage instances in the same namespace |
| nodeSelector | object | `{}` | pod node selector |
| podAnnotations | object | `{}` | pod annotations |
| podSecurityContext | object | `{}` | pod security context |
| priorityClassName | string | `""` | pod priority class name |
| resources | object | `{}` | grafana operator container resources |
| securityContext | object | `{"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true}` | grafana operator container security context |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| tolerations | list | `[]` | pod tolerations |
| watchNamespaces | string | `""` | Sets the WATCH_NAMESPACE environment variable, it defines which namespaces the operator should be listening for. By default it's all namespaces, if you only want to listen for the same namespace as the operator is deployed to look at namespaceScope. |
