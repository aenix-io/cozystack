# kamaji-etcd

![Version: 0.5.1](https://img.shields.io/badge/Version-0.5.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 3.5.6](https://img.shields.io/badge/AppVersion-3.5.6-informational?style=flat-square)

Helm chart for deploying a multi-tenant `etcd` cluster.

[Kamaji](https://github.com/clastix/kamaji) turns any Kubernetes cluster into an _admin cluster_ to orchestrate other Kubernetes clusters called _tenant clusters_.
The Control Plane of a _tenant cluster_ is made of regular pods running in a namespace of the _admin cluster_ instead of a dedicated set of Virtual Machines.
This solution makes running control planes at scale cheaper and easier to deploy and operate.

As of any Kubernetes cluster, a _tenant cluster_ needs a datastore where to save the state and be able to retrieve data.
This chart provides a multi-tenant `etcd` as datastore for Kamaji as well as a standalone multi-tenant `etcd` cluster.

## Install kamaji-etcd

To install the Chart with the release name `kamaji-etcd`:

        helm repo add clastix https://clastix.github.io/charts
        helm repo update
        helm install kamaji-etcd clastix/kamaji-etcd -n kamaji-etcd --create-namespace

Show the status:

        helm status kamaji-etcd -n kamaji-etcd

Upgrade the Chart

        helm upgrade kamaji-etcd -n kamaji-etcd clastix/kamaji-etcd

Uninstall the Chart

        helm uninstall kamaji-etcd -n kamaji-etcd

## Customize the installation

There are two methods for specifying overrides of values during Chart installation: `--values` and `--set`.

The `--values` option is the preferred method because it allows you to keep your overrides in a YAML file, rather than specifying them all on the command line.
Create a copy of the YAML file `values.yaml` and add your overrides to it.

Specify your overrides file when you install the Chart:

        helm upgrade kamaji-etcd --install --namespace kamaji-etcd --create-namespacekamaji-etcd --values myvalues.yaml

The values in your overrides file `myvalues.yaml` will override their counterparts in the Chart's values.yaml file.
Any values in `values.yaml` that weren't overridden will keep their defaults.

If you only need to make minor customizations, you can specify them on the command line by using the `--set` option. For example:

        helm upgrade kamaji-etcd --install --namespace kamaji-etcd --create-namespace kamaji-etcd --set replicas=5

Here the values you can override:

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Kubernetes affinity rules to apply to etcd controller pods |
| alerts.annotations | object | `{}` | Assign additional Annotations |
| alerts.enabled | bool | `false` | Enable alerts for Alertmanager |
| alerts.labels | object | `{}` | Assign additional labels according to Prometheus' Alerts matching labels |
| alerts.namespace | string | `""` | Install the Alerts into a different Namespace, as the monitoring stack one (default: the release one) |
| alerts.rules | list | `[]` | The rules for alerts |
| autoCompactionMode | string | `"periodic"` | Interpret 'auto-compaction-retention' one of: periodic|revision. Use 'periodic' for duration based retention, 'revision' for revision number based retention. |
| autoCompactionRetention | string | `"5m"` | Auto compaction retention length. 0 means disable auto compaction. |
| backup | object | `{"all":false,"enabled":false,"s3":{"accessKey":{"value":"","valueFrom":{}},"bucket":"mybucket","image":{"pullPolicy":"IfNotPresent","repository":"minio/mc","tag":"RELEASE.2022-11-07T23-47-39Z"},"retention":"","secretKey":{"value":"","valueFrom":{}},"url":"http://mys3storage:9000"},"schedule":"20 3 * * *","snapshotDateFormat":"$(date +%Y%m%d)","snapshotNamePrefix":"mysnapshot"}` | Enable storage backup  |
| backup.all | bool | `false` | Enable backup for all endpoints. When disabled, only the leader will be taken |
| backup.enabled | bool | `false` | Enable scheduling backup job |
| backup.s3 | object | `{"accessKey":{"value":"","valueFrom":{}},"bucket":"mybucket","image":{"pullPolicy":"IfNotPresent","repository":"minio/mc","tag":"RELEASE.2022-11-07T23-47-39Z"},"retention":"","secretKey":{"value":"","valueFrom":{}},"url":"http://mys3storage:9000"}` | The S3 storage config section |
| backup.s3.accessKey | object | `{"value":"","valueFrom":{}}` | The S3 storage ACCESS KEY credential. The plain value has precedence over the valueFrom that can be used to retrieve the value from a Secret. |
| backup.s3.bucket | string | `"mybucket"` | The S3 storage bucket |
| backup.s3.image | object | `{"pullPolicy":"IfNotPresent","repository":"minio/mc","tag":"RELEASE.2022-11-07T23-47-39Z"}` | The S3 client image config section |
| backup.s3.image.pullPolicy | string | `"IfNotPresent"` | Pull policy to use |
| backup.s3.image.repository | string | `"minio/mc"` | Install image from specific repo  |
| backup.s3.image.tag | string | `"RELEASE.2022-11-07T23-47-39Z"` | Install image with specific tag |
| backup.s3.retention | string | `""` | The S3 storage object lifecycle management rules; N.B. enabling this option will delete previously set lifecycle rules |
| backup.s3.secretKey | object | `{"value":"","valueFrom":{}}` | The S3 storage SECRET KEY credential. The plain value has precedence over the valueFrom that can be used to retrieve the value from a Secret. |
| backup.s3.url | string | `"http://mys3storage:9000"` | The S3 storage url |
| backup.schedule | string | `"20 3 * * *"` | The job scheduled maintenance time for backup |
| backup.snapshotDateFormat | string | `"$(date +%Y%m%d)"` | The backup file date format (bash) |
| backup.snapshotNamePrefix | string | `"mysnapshot"` | The backup file name prefix |
| clientPort | int | `2379` | The client request port. |
| datastore.enabled | bool | `false` | Create a datastore custom resource for Kamaji |
| defragmentation | object | `{"schedule":"*/15 * * * *"}` | Enable storage defragmentation  |
| defragmentation.schedule | string | `"*/15 * * * *"` | The job scheduled maintenance time for defrag (empty to disable) |
| extraArgs | list | `[]` | A list of extra arguments to add to the etcd default ones |
| image.pullPolicy | string | `"IfNotPresent"` | Pull policy to use |
| image.repository | string | `"quay.io/coreos/etcd"` | Install image from specific repo  |
| image.tag | string | `""` | Install image with specific tag, overwrite the tag in the chart |
| livenessProbe | object | `{}` | The livenessProbe for the etcd container |
| metricsPort | int | `2381` | The port where etcd exposes metrics. |
| nodeSelector | object | `{"kubernetes.io/os":"linux"}` | Kubernetes node selector rules to schedule etcd |
| peerApiPort | int | `2380` | The peer API port which servers are listening to. |
| persistentVolumeClaim.accessModes | list | `["ReadWriteOnce"]` | The Access Mode to storage |
| persistentVolumeClaim.customAnnotations | object | `{}` | The custom annotations to add to the PVC |
| persistentVolumeClaim.size | string | `"10Gi"` | The size of persistent storage for etcd data  |
| persistentVolumeClaim.storageClassName | string | `""` | A specific storage class |
| podAnnotations | object | `{}` | Annotations to add to all etcd pods |
| podLabels | object | `{"application":"kamaji-etcd"}` | Labels to add to all etcd pods |
| priorityClassName | string | `"system-cluster-critical"` | The priorityClassName to apply to etcd |
| quotaBackendBytes | string | `"8589934592"` | Raise alarms when backend size exceeds the given quota. It will put the cluster into a maintenance mode which only accepts key reads and deletes.  |
| replicas | int | `3` | Size of the etcd cluster |
| resources | object | `{"limits":{},"requests":{}}` | Resources assigned to the etcd containers |
| securityContext | object | `{"allowPrivilegeEscalation":false}` | The securityContext to apply to etcd |
| serviceAccount | object | `{"create":true,"name":""}` | Install an etcd with enabled multi-tenancy |
| serviceAccount.create | bool | `true` | Create a ServiceAccount, required to install and provision the etcd backing storage (default: true) |
| serviceAccount.name | string | `""` | Define the ServiceAccount name to use during the setup and provision of the etcd backing storage (default: "") |
| serviceMonitor.annotations | object | `{}` | Assign additional Annotations |
| serviceMonitor.enabled | bool | `false` | Enable ServiceMonitor for Prometheus |
| serviceMonitor.endpoint.interval | string | `"15s"` | Set the scrape interval for the endpoint of the serviceMonitor |
| serviceMonitor.endpoint.metricRelabelings | list | `[]` | Set metricRelabelings for the endpoint of the serviceMonitor |
| serviceMonitor.endpoint.relabelings | list | `[]` | Set relabelings for the endpoint of the serviceMonitor |
| serviceMonitor.endpoint.scrapeTimeout | string | `""` | Set the scrape timeout for the endpoint of the serviceMonitor |
| serviceMonitor.labels | object | `{}` | Assign additional labels according to Prometheus' serviceMonitorSelector matching labels |
| serviceMonitor.matchLabels | object | `{}` | Change matching labels |
| serviceMonitor.namespace | string | `""` | Install the ServiceMonitor into a different Namespace, as the monitoring stack one (default: the release one) |
| serviceMonitor.serviceAccount.name | string | `"etcd"` | ServiceAccount for Metrics RBAC |
| serviceMonitor.serviceAccount.namespace | string | `"etcd-system"` | ServiceAccount Namespace for Metrics RBAC |
| serviceMonitor.targetLabels | list | `[]` | Set targetLabels for the serviceMonitor |
| snapshotCount | string | `"10000"` | Number of committed transactions to trigger a snapshot to disk. |
| tolerations | list | `[]` | Kubernetes node taints that the etcd pods would tolerate |
| topologySpreadConstraints | list | `[]` | Kubernetes topology spread constraints to apply to etcd controller pods |

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Adriano Pezzuto | <me@bsctl.io> |  |
| Dario Tranchitella | <dario@tranchitella.eu> |  |

## Source Code

* <https://github.com/clastix/kamaji-etcd>
