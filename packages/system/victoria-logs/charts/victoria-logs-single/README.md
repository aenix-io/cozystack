# Victoria Logs Helm Chart for Single Version

 ![Version: 0.6.0](https://img.shields.io/badge/Version-0.6.0-informational?style=flat-square)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/victoriametrics)](https://artifacthub.io/packages/helm/victoriametrics/victoria-logs-single)
[![Slack](https://img.shields.io/badge/join%20slack-%23victoriametrics-brightgreen.svg)](https://slack.victoriametrics.com/)

Victoria Logs Single version - high-performance, cost-effective and scalable logs storage

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).

* PV support on underlying infrastructure.

## Chart Details

This chart will do the following:

* Rollout Victoria Logs Single.
* (optional) Rollout [fluentbit](https://fluentbit.io/) to collect logs from pods.

Chart allows to configure logs collection from Kubernetes pods to VictoriaLogs.
In order to do that you need to enable fluentbit:
```yaml
fluent-bit:
  enabled: true
```
By default, fluentbit will forward logs to VictoriaLogs installation deployed by this chart.

## How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-logs-single`` chart available to installation:

```console
helm search repo vm/victoria-logs-single -l
```

Export default values of ``victoria-logs-single`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-logs-single > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install vlsingle vm/victoria-logs-single -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

```console
helm install vlsingle vm/victoria-logs-single -f values.yaml -n NAMESPACE
```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'single'
```

Get the application by running this command:

```console
helm list -f vlsingle -n NAMESPACE
```

See the history of versions of ``vlsingle`` application with command.

```console
helm history vlsingle -n NAMESPACE
```

## How to uninstall

Remove application with command.

```console
helm uninstall vlsingle -n NAMESPACE
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-logs-single

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-logs-single/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extraObjects | list | `[]` |  |
| fluent-bit.config.filters | string | `"[FILTER]\n    Name kubernetes\n    Match kube.*\n    Merge_Log On\n    Keep_Log On\n    K8S-Logging.Parser On\n    K8S-Logging.Exclude On\n[FILTER]\n    Name                nest\n    Match               *\n    Wildcard            pod_name\n    Operation lift\n    Nested_under kubernetes\n    Add_prefix   kubernetes_\n"` |  |
| fluent-bit.config.outputs | string | `"[OUTPUT]\n    Name http\n    Match kube.*\n    Host {{ include \"victoria-logs.server.fullname\" . }}\n    port 9428\n    compress gzip\n    uri /insert/jsonline?_stream_fields=stream,kubernetes_pod_name,kubernetes_container_name,kubernetes_namespace_name&_msg_field=log&_time_field=date\n    format json_lines\n    json_date_format iso8601\n    header AccountID 0\n    header ProjectID 0\n"` | Note that Host must be replaced to match your VictoriaLogs service name Default format points to VictoriaLogs service. |
| fluent-bit.daemonSetVolumeMounts[0].mountPath | string | `"/var/log"` |  |
| fluent-bit.daemonSetVolumeMounts[0].name | string | `"varlog"` |  |
| fluent-bit.daemonSetVolumeMounts[1].mountPath | string | `"/var/lib/docker/containers"` |  |
| fluent-bit.daemonSetVolumeMounts[1].name | string | `"varlibdockercontainers"` |  |
| fluent-bit.daemonSetVolumeMounts[1].readOnly | bool | `true` |  |
| fluent-bit.daemonSetVolumes[0].hostPath.path | string | `"/var/log"` |  |
| fluent-bit.daemonSetVolumes[0].name | string | `"varlog"` |  |
| fluent-bit.daemonSetVolumes[1].hostPath.path | string | `"/var/lib/docker/containers"` |  |
| fluent-bit.daemonSetVolumes[1].name | string | `"varlibdockercontainers"` |  |
| fluent-bit.enabled | bool | `false` | Enable deployment of fluent-bit |
| fluent-bit.resources | object | `{}` |  |
| global.compatibility.openshift.adaptSecurityContext | string | `"auto"` |  |
| global.image.registry | string | `""` |  |
| global.imagePullSecrets | list | `[]` |  |
| global.nameOverride | string | `""` |  |
| global.victoriaLogs.server.fullnameOverride | string | `nil` | Overrides the full name of server component |
| global.victoriaLogs.server.name | string | `"server"` | Server container name |
| podDisruptionBudget.enabled | bool | `false` | See `kubectl explain poddisruptionbudget.spec` for more. Ref: [https://kubernetes.io/docs/tasks/run-application/configure-pdb/](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) |
| podDisruptionBudget.extraLabels | object | `{}` |  |
| printNotes | bool | `true` | Print chart notes |
| server.affinity | object | `{}` | Pod affinity |
| server.containerWorkingDir | string | `""` | Container workdir |
| server.emptyDir | object | `{}` |  |
| server.enabled | bool | `true` | Enable deployment of server component. Deployed as StatefulSet |
| server.env | list | `[]` | Additional environment variables (ex.: secret tokens, flags) https://github.com/VictoriaMetrics/VictoriaMetrics#environment-variables |
| server.envFrom | list | `[]` |  |
| server.extraArgs."envflag.enable" | string | `"true"` |  |
| server.extraArgs."envflag.prefix" | string | `"VM_"` |  |
| server.extraArgs.loggerFormat | string | `"json"` |  |
| server.extraContainers | list | `[]` |  |
| server.extraHostPathMounts | list | `[]` |  |
| server.extraLabels | object | `{}` | Sts/Deploy additional labels |
| server.extraVolumeMounts | list | `[]` |  |
| server.extraVolumes | list | `[]` |  |
| server.image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| server.image.registry | string | `""` | Image registry |
| server.image.repository | string | `"victoriametrics/victoria-logs"` | Image repository |
| server.image.tag | string | `""` | Image tag |
| server.image.variant | string | `"victorialogs"` |  |
| server.imagePullSecrets | list | `[]` | Image pull secrets |
| server.ingress.annotations | string | `nil` | Ingress annotations |
| server.ingress.enabled | bool | `false` | Enable deployment of ingress for server component |
| server.ingress.extraLabels | object | `{}` | Ingress extra labels |
| server.ingress.hosts | list | `[]` |  |
| server.ingress.pathType | string | `"Prefix"` | pathType is only for k8s >= 1.1= |
| server.ingress.tls | list | `[]` | Array of TLS objects |
| server.initContainers | list | `[]` |  |
| server.nodeSelector | object | `{}` | Pod's node selector. Ref: [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/) |
| server.persistentVolume.accessModes | list | `["ReadWriteOnce"]` | Array of access modes. Must match those of existing PV or dynamic provisioner. Ref: [http://kubernetes.io/docs/user-guide/persistent-volumes/](http://kubernetes.io/docs/user-guide/persistent-volumes/) |
| server.persistentVolume.annotations | object | `{}` | Persistant volume annotations |
| server.persistentVolume.enabled | bool | `false` | Create/use Persistent Volume Claim for server component. Empty dir if false |
| server.persistentVolume.existingClaim | string | `""` | Existing Claim name. If defined, PVC must be created manually before volume will be bound |
| server.persistentVolume.matchLabels | object | `{}` | Bind Persistent Volume by labels. Must match all labels of targeted PV. |
| server.persistentVolume.mountPath | string | `"/storage"` | Mount path. Server data Persistent Volume mount root path. |
| server.persistentVolume.size | string | `"3Gi"` | Size of the volume. Should be calculated based on the logs you send and retention policy you set. |
| server.persistentVolume.storageClass | string | `""` | StorageClass to use for persistent volume. Requires server.persistentVolume.enabled: true. If defined, PVC created automatically |
| server.persistentVolume.subPath | string | `""` | Mount subpath |
| server.podAnnotations | object | `{}` | Pod's annotations |
| server.podLabels | object | `{}` | Pod's additional labels |
| server.podManagementPolicy | string | `"OrderedReady"` | Pod's management policy |
| server.podSecurityContext | object | `{"enabled":true,"fsGroup":2000,"runAsNonRoot":true,"runAsUser":1000}` | Pod's security context. Ref: [https://kubernetes.io/docs/tasks/configure-pod-container/security-context/](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) |
| server.priorityClassName | string | `""` | Name of Priority Class |
| server.probe.liveness.failureThreshold | int | `10` |  |
| server.probe.liveness.initialDelaySeconds | int | `30` |  |
| server.probe.liveness.periodSeconds | int | `30` |  |
| server.probe.liveness.tcpSocket.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| server.probe.liveness.timeoutSeconds | int | `5` |  |
| server.probe.readiness.failureThreshold | int | `3` |  |
| server.probe.readiness.httpGet.path | string | `"{{ include \"vm.probe.http.path\" . }}"` |  |
| server.probe.readiness.httpGet.port | string | `"{{ include \"vm.probe.port\" . }}"` |  |
| server.probe.readiness.httpGet.scheme | string | `"{{ include \"vm.probe.http.scheme\" . }}"` |  |
| server.probe.readiness.initialDelaySeconds | int | `5` |  |
| server.probe.readiness.periodSeconds | int | `15` |  |
| server.probe.readiness.timeoutSeconds | int | `5` |  |
| server.probe.startup | object | `{}` |  |
| server.resources | object | `{}` | Resource object. Ref: [http://kubernetes.io/docs/user-guide/compute-resources/](http://kubernetes.io/docs/user-guide/compute-resources/ |
| server.retentionPeriod | int | `1` | Data retention period in month |
| server.securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"enabled":true,"readOnlyRootFilesystem":true}` | Security context to be added to server pods |
| server.service.annotations | object | `{}` | Service annotations |
| server.service.clusterIP | string | `""` | Service ClusterIP |
| server.service.externalIPs | list | `[]` | Service External IPs. Ref: [https://kubernetes.io/docs/user-guide/services/#external-ips]( https://kubernetes.io/docs/user-guide/services/#external-ips) |
| server.service.externalTrafficPolicy | string | `""` |  |
| server.service.healthCheckNodePort | string | `""` |  |
| server.service.ipFamilies | list | `[]` |  |
| server.service.ipFamilyPolicy | string | `""` |  |
| server.service.labels | object | `{}` | Service labels |
| server.service.loadBalancerIP | string | `""` | Service load balacner IP |
| server.service.loadBalancerSourceRanges | list | `[]` | Load balancer source range |
| server.service.servicePort | int | `9428` | Service port |
| server.service.type | string | `"ClusterIP"` | Service type |
| server.serviceMonitor.annotations | object | `{}` | Service Monitor annotations |
| server.serviceMonitor.basicAuth | object | `{}` | Basic auth params for Service Monitor |
| server.serviceMonitor.enabled | bool | `false` | Enable deployment of Service Monitor for server component. This is Prometheus operator object |
| server.serviceMonitor.extraLabels | object | `{}` | Service Monitor labels |
| server.serviceMonitor.metricRelabelings | list | `[]` | Service Monitor metricRelabelings |
| server.serviceMonitor.relabelings | list | `[]` | Service Monitor relabelings |
| server.statefulSet.enabled | bool | `true` | Creates statefulset instead of deployment, useful when you want to keep the cache |
| server.statefulSet.podManagementPolicy | string | `"OrderedReady"` | Deploy order policy for StatefulSet pods |
| server.terminationGracePeriodSeconds | int | `60` | Pod's termination grace period in seconds |
| server.tolerations | list | `[]` | Node tolerations for server scheduling to nodes with taints. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |
