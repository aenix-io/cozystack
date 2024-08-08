# kamaji

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v1.0.0](https://img.shields.io/badge/AppVersion-v1.0.0-informational?style=flat-square)

Kamaji is the Hosted Control Plane Manager for Kubernetes.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Dario Tranchitella | <dario@tranchitella.eu> | <https://clastix.io> |
| Massimiliano Giovagnoli | <me@maxgio.it> |  |
| Adriano Pezzuto | <me@bsctl.io> | <https://clastix.io> |

## Source Code

* <https://github.com/clastix/kamaji>

## Requirements

Kubernetes: `>=1.21.0-0`

[Kamaji](https://github.com/clastix/kamaji) requires a [multi-tenant `etcd`](https://github.com/clastix/kamaji-internal/blob/master/deploy/getting-started-with-kamaji.md#setup-internal-multi-tenant-etcd) cluster.
This Helm Chart starting from v0.1.1 provides the installation of an internal `etcd` in order to streamline the local test. If you'd like to use an externally managed etcd instance, you can specify the overrides and by setting the value `etcd.deploy=false`.

> For production use an externally managed `etcd` is highly recommended, the `etcd` addon offered by this Chart is not considered production-grade.

## Install Kamaji

To install the Chart with the release name `kamaji`:

        helm upgrade --install --namespace kamaji-system --create-namespace clastix/kamaji

Show the status:

        helm status kamaji -n kamaji-system

Upgrade the Chart

        helm upgrade kamaji -n kamaji-system clastix/kamaji

Uninstall the Chart

        helm uninstall kamaji -n kamaji-system

## Customize the installation

There are two methods for specifying overrides of values during Chart installation: `--values` and `--set`.

The `--values` option is the preferred method because it allows you to keep your overrides in a YAML file, rather than specifying them all on the command line. Create a copy of the YAML file `values.yaml` and add your overrides to it.

Specify your overrides file when you install the Chart:

        helm upgrade kamaji --install --namespace kamaji-system --create-namespace clastix/kamaji --values myvalues.yaml

The values in your overrides file `myvalues.yaml` will override their counterparts in the Chart's values.yaml file. Any values in `values.yaml` that weren’t overridden will keep their defaults.

If you only need to make minor customizations, you can specify them on the command line by using the `--set` option. For example:

        helm upgrade kamaji --install --namespace kamaji-system --create-namespace clastix/kamaji --set etcd.deploy=false

Here the values you can override:

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Kubernetes affinity rules to apply to Kamaji controller pods |
| cfssl.image.repository | string | `"cfssl/cfssl"` |  |
| cfssl.image.tag | string | `"latest"` |  |
| datastore.basicAuth.passwordSecret.keyPath | string | `nil` | The Secret key where the data is stored. |
| datastore.basicAuth.passwordSecret.name | string | `nil` | The name of the Secret containing the password used to connect to the relational database. |
| datastore.basicAuth.passwordSecret.namespace | string | `nil` | The namespace of the Secret containing the password used to connect to the relational database. |
| datastore.basicAuth.usernameSecret.keyPath | string | `nil` | The Secret key where the data is stored. |
| datastore.basicAuth.usernameSecret.name | string | `nil` | The name of the Secret containing the username used to connect to the relational database. |
| datastore.basicAuth.usernameSecret.namespace | string | `nil` | The namespace of the Secret containing the username used to connect to the relational database. |
| datastore.driver | string | `"etcd"` | (string) The Kamaji Datastore driver, supported: etcd, MySQL, PostgreSQL (defaults=etcd). |
| datastore.enabled | bool | `true` | (bool) Enable the Kamaji Datastore creation (default=true) |
| datastore.endpoints | list | `[]` | (array) List of endpoints of the selected Datastore. When letting the Chart install the etcd datastore, this field is populated automatically. |
| datastore.nameOverride | string | `nil` | The Datastore name override, if empty and enabled=true defaults to `default`, if enabled=false, this is the name of the Datastore to connect to. |
| datastore.tlsConfig.certificateAuthority.certificate.keyPath | string | `nil` | Key of the Secret which contains the content of the certificate. |
| datastore.tlsConfig.certificateAuthority.certificate.name | string | `nil` | Name of the Secret containing the CA required to establish the mandatory SSL/TLS connection to the datastore. |
| datastore.tlsConfig.certificateAuthority.certificate.namespace | string | `nil` | Namespace of the Secret containing the CA required to establish the mandatory SSL/TLS connection to the datastore. |
| datastore.tlsConfig.certificateAuthority.privateKey.keyPath | string | `nil` | Key of the Secret which contains the content of the private key. |
| datastore.tlsConfig.certificateAuthority.privateKey.name | string | `nil` | Name of the Secret containing the CA private key required to establish the mandatory SSL/TLS connection to the datastore. |
| datastore.tlsConfig.certificateAuthority.privateKey.namespace | string | `nil` | Namespace of the Secret containing the CA private key required to establish the mandatory SSL/TLS connection to the datastore. |
| datastore.tlsConfig.clientCertificate.certificate.keyPath | string | `nil` | Key of the Secret which contains the content of the certificate. |
| datastore.tlsConfig.clientCertificate.certificate.name | string | `nil` | Name of the Secret containing the client certificate required to establish the mandatory SSL/TLS connection to the datastore. |
| datastore.tlsConfig.clientCertificate.certificate.namespace | string | `nil` | Namespace of the Secret containing the client certificate required to establish the mandatory SSL/TLS connection to the datastore. |
| datastore.tlsConfig.clientCertificate.privateKey.keyPath | string | `nil` | Key of the Secret which contains the content of the private key. |
| datastore.tlsConfig.clientCertificate.privateKey.name | string | `nil` | Name of the Secret containing the client certificate private key required to establish the mandatory SSL/TLS connection to the datastore. |
| datastore.tlsConfig.clientCertificate.privateKey.namespace | string | `nil` | Namespace of the Secret containing the client certificate private key required to establish the mandatory SSL/TLS connection to the datastore. |
| datastore.tlsConfig.enabled | bool | `true` |  |
| etcd.compactionInterval | int | `0` | ETCD Compaction interval (e.g. "5m0s"). (default: "0" (disabled)) |
| etcd.deploy | bool | `true` | Install an etcd with enabled multi-tenancy along with Kamaji |
| etcd.image | object | `{"pullPolicy":"IfNotPresent","repository":"quay.io/coreos/etcd","tag":"v3.5.6"}` | Install specific etcd image |
| etcd.livenessProbe | object | `{"failureThreshold":8,"httpGet":{"path":"/health?serializable=true","port":2381,"scheme":"HTTP"},"initialDelaySeconds":10,"periodSeconds":10,"timeoutSeconds":15}` | The livenessProbe for the etcd container |
| etcd.overrides.caSecret.name | string | `"etcd-certs"` | Name of the secret which contains CA's certificate and private key. (default: "etcd-certs") |
| etcd.overrides.caSecret.namespace | string | `"kamaji-system"` | Namespace of the secret which contains CA's certificate and private key. (default: "kamaji-system") |
| etcd.overrides.clientSecret.name | string | `"root-client-certs"` | Name of the secret which contains ETCD client certificates. (default: "root-client-certs") |
| etcd.overrides.clientSecret.namespace | string | `"kamaji-system"` | Name of the namespace where the secret which contains ETCD client certificates is. (default: "kamaji-system") |
| etcd.overrides.endpoints | object | `{"etcd-0":"etcd-0.etcd.kamaji-system.svc.cluster.local","etcd-1":"etcd-1.etcd.kamaji-system.svc.cluster.local","etcd-2":"etcd-2.etcd.kamaji-system.svc.cluster.local"}` | (map) Dictionary of the endpoints for the etcd cluster's members, key is the name of the etcd server. Don't define the protocol (TLS is automatically inflected), or any port, inflected from .etcd.peerApiPort value. |
| etcd.peerApiPort | int | `2380` | The peer API port which servers are listening to. |
| etcd.persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| etcd.persistence.customAnnotations | object | `{}` | The custom annotations to add to the PVC |
| etcd.persistence.size | string | `"10Gi"` |  |
| etcd.persistence.storageClassName | string | `""` |  |
| etcd.port | int | `2379` | The client request port. |
| etcd.serviceAccount.create | bool | `true` | Create a ServiceAccount, required to install and provision the etcd backing storage (default: true) |
| etcd.serviceAccount.name | string | `""` | Define the ServiceAccount name to use during the setup and provision of the etcd backing storage (default: "") |
| etcd.tolerations | list | `[]` | (array) Kubernetes affinity rules to apply to Kamaji etcd pods |
| extraArgs | list | `[]` | A list of extra arguments to add to the kamaji controller default ones |
| fullnameOverride | string | `""` |  |
| healthProbeBindAddress | string | `":8081"` | The address the probe endpoint binds to. (default ":8081") |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"clastix/kamaji"` | The container image of the Kamaji controller. |
| image.tag | string | `nil` | Overrides the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` |  |
| livenessProbe | object | `{"httpGet":{"path":"/healthz","port":"healthcheck"},"initialDelaySeconds":15,"periodSeconds":20}` | The livenessProbe for the controller container |
| loggingDevel.enable | bool | `false` | (string) Development Mode defaults(encoder=consoleEncoder,logLevel=Debug,stackTraceLevel=Warn). Production Mode defaults(encoder=jsonEncoder,logLevel=Info,stackTraceLevel=Error) (default false) |
| metricsBindAddress | string | `":8080"` | (string) The address the metric endpoint binds to. (default ":8080") |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` | Kubernetes node selector rules to schedule Kamaji controller |
| podAnnotations | object | `{}` | The annotations to apply to the Kamaji controller pods. |
| podSecurityContext | object | `{"runAsNonRoot":true}` | The securityContext to apply to the Kamaji controller pods. |
| readinessProbe | object | `{"httpGet":{"path":"/readyz","port":"healthcheck"},"initialDelaySeconds":5,"periodSeconds":10}` | The readinessProbe for the controller container |
| replicaCount | int | `1` | The number of the pod replicas for the Kamaji controller. |
| resources.limits.cpu | string | `"200m"` |  |
| resources.limits.memory | string | `"100Mi"` |  |
| resources.requests.cpu | string | `"100m"` |  |
| resources.requests.memory | string | `"20Mi"` |  |
| securityContext | object | `{"allowPrivilegeEscalation":false}` | The securityContext to apply to the Kamaji controller container only. It does not apply to the Kamaji RBAC proxy container. |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"kamaji-controller-manager"` |  |
| serviceMonitor.enabled | bool | `false` | Toggle the ServiceMonitor true if you have Prometheus Operator installed and configured |
| telemetry | object | `{"disabled":false}` | Disable the analytics traces collection |
| temporaryDirectoryPath | string | `"/tmp/kamaji"` | Directory which will be used to work with temporary files. (default "/tmp/kamaji") |
| tolerations | list | `[]` | Kubernetes node taints that the Kamaji controller pods would tolerate |

## Installing and managing etcd as DataStore

Kamaji supports multiple data store, although `etcd` is the default one: thus, an initial cluster will be created upon the Chart installation.

The `DataStore` resource can be configured with the proper values in case of overrides when using a different driver, otherwise all the required data will be inherited by the Chart values.
