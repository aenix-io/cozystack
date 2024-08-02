# seaweedfs-operator

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

A Helm chart for the seaweedfs-operator

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| chrislusf |  | <https://github.com/chrislusf> |

## Values

| Key                             | Type   | Default                         | Description                                                                                                                                                                                                          |
|---------------------------------|--------|---------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| commonAnnotations               | object | `{}`                            | Annotations for all the deployed objects                                                                                                                                                                             |
| commonLabels                    | object | `{}`                            | Labels for all the deployed objects                                                                                                                                                                                  |
| fullnameOverride                | string | `""`                            | String to fully override common.names.fullname template                                                                                                                                                              |
| global                          | object | `{"imageRegistry":"chrislusf"}` | Global Docker image parameters Please, note that this will override the image parameters, including dependencies, configured to use the global value Current available global Docker image parameters: imageRegistry |
| grafanaDashboard.enabled        | bool   | `true`                          | Enable or disable Grafana Dashboard configmap                                                                                                                                                                        |
| image.pullPolicy                | string | `"Always"`                      | Specify a imagePullPolicy # Defaults to 'Always' if image tag is 'latest', else set to 'IfNotPresent' # ref: http://kubernetes.io/docs/user-guide/images/#pre-pulling-images                                         |
| image.registry                  | string | `"chrislusf"`                   |                                                                                                                                                                                                                      |
| image.repository                | string | `"seaweedfs-operator"`          |                                                                                                                                                                                                                      |
| image.tag                       | string | `""`                            | tag of image to use. Defaults to appVersion in Chart.yaml                                                                                                                                                            |
| nameOverride                    | string | `""`                            | String to partially override common.names.fullname template (will maintain the release name)                                                                                                                         |
| port.name                       | string | `"http"`                        | name of the container port to use for the Kubernete service and ingress                                                                                                                                              |
| port.number                     | int    | `8080`                          | container port number to use for the Kubernete service and ingress                                                                                                                                                   |
| rbac.serviceAccount.name        | string | `"default"`                     | name of the Kubernetes service account to create                                                                                                                                                                     |
| replicaCount                    | int    | `1`                             | Set number of pod replicas                                                                                                                                                                                           |
| resources.limits.cpu            | string | `"500m"`                        | seaweedfs-operator containers' cpu limit (maximum allowes CPU)                                                                                                                                                       |
| resources.limits.memory         | string | `"500Mi"`                       | seaweedfs-operator containers' memory limit (maximum allowes memory)                                                                                                                                                 |
| resources.requests.cpu          | string | `"100m"`                        | seaweedfs-operator containers' cpu request (how much is requested by default)                                                                                                                                        |
| resources.requests.memory       | string | `"50Mi"`                        | seaweedfs-operator containers' memory request (how much is requested by default)                                                                                                                                     |
| service.port                    | int    | `8080`                          | port to use for Kubernetes service                                                                                                                                                                                   |
| service.portName                | string | `"http"`                        | name of the port to use for Kubernetes service                                                                                                                                                                       |
| serviceMonitor.additionalLabels | object | `{}`                            | Used to pass Labels that are used by the Prometheus installed in your cluster to select Service Monitors to work with                                                                                                |
| serviceMonitor.enabled          | bool   | `true`                          | Enable or disable ServiceMonitor for prometheus metrics                                                                                                                                                              |
| serviceMonitor.honorLabels      | bool   | `true`                          | Specify honorLabels parameter to add the scrape endpoint                                                                                                                                                             |
| serviceMonitor.interval         | string | `"10s"`                         | Specify the interval at which metrics should be scraped                                                                                                                                                              |
| serviceMonitor.scrapeTimeout    | string | `"10s"`                         | Specify the timeout after which the scrape is ended                                                                                                                                                                  |
| webhook.enabled                 | bool   | `true`                          | Enable or disable webhooks                                                                                                                                                                                           |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.3](https://github.com/norwoodj/helm-docs/releases/v1.11.3)
