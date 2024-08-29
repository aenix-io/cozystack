# Helm Chart For Victoria Metrics Operator.

![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)  ![Version: 0.34.5](https://img.shields.io/badge/Version-0.34.5-informational?style=flat-square)
[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/victoriametrics)](https://artifacthub.io/packages/helm/victoriametrics/victoria-metrics-operator)

Victoria Metrics Operator

## Prerequisites

* Install the follow packages: ``git``, ``kubectl``, ``helm``, ``helm-docs``. See this [tutorial](../../REQUIREMENTS.md).
* PV support on underlying infrastructure.

## ArgoCD issues

When running operator using ArgoCD without Cert Manager (`.Values.admissionWebhooks.certManager.enabled: false`) it will rerender webhook certificates
on each sync since Helm `lookup` function is not respected by ArgoCD. To prevent this please update you operator Application `spec.syncPolicy` and `spec.ignoreDifferences` with a following:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
...
spec:
  ...
  syncPolicy:
    syncOptions:
    # https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#respect-ignore-difference-configs
    # argocd must also ignore difference during apply stage
    # otherwise it ll silently override changes and cause a problem
    - RespectIgnoreDifferences=true
  ignoreDifferences:
    - group: ""
      kind: Secret
      name: <fullname>-validation
      namespace: kube-system
      jsonPointers:
        - /data
    - group: admissionregistration.k8s.io
      kind: ValidatingWebhookConfiguration
      name: <fullname>-admission
      jqPathExpressions:
      - '.webhooks[]?.clientConfig.caBundle'
```
where `<fullname>` is output of `{{ include "vm-operator.fullname" }}` for your setup

## Upgrade guide

 During release an issue with helm CRD was discovered. So for upgrade from version less then 0.1.3 you have to two options:
 1) use helm management for CRD, enabled by default.
 2) use own management system, need to add variable: --set createCRD=false.

If you choose helm management, following steps must be done before upgrade:

1) define namespace and helm release name variables

```
export NAMESPACE=default
export RELEASE_NAME=operator
```

execute kubectl commands:

```
kubectl get crd  | grep victoriametrics.com | awk '{print $1 }' | xargs -i kubectl label crd {} app.kubernetes.io/managed-by=Helm --overwrite
kubectl get crd  | grep victoriametrics.com | awk '{print $1 }' | xargs -i kubectl annotate crd {} meta.helm.sh/release-namespace="$NAMESPACE" meta.helm.sh/release-name="$RELEASE_NAME"  --overwrite
```

run helm upgrade command.

## Chart Details

This chart will do the following:

* Rollout victoria metrics operator

## How to install

Access a Kubernetes cluster.

Add a chart helm repository with follow commands:

```console
helm repo add vm https://victoriametrics.github.io/helm-charts/

helm repo update
```

List versions of ``vm/victoria-metrics-operator`` chart available to installation:

```console
helm search repo vm/victoria-metrics-operator -l
```

Export default values of ``victoria-metrics-operator`` chart to file ``values.yaml``:

```console
helm show values vm/victoria-metrics-operator > values.yaml
```

Change the values according to the need of the environment in ``values.yaml`` file.

Test the installation with command:

```console
helm install vmoperator vm/victoria-metrics-operator -f values.yaml -n NAMESPACE --debug --dry-run
```

Install chart with command:

```console
helm install vmoperator vm/victoria-metrics-operator -f values.yaml -n NAMESPACE
```

Get the pods lists by running this commands:

```console
kubectl get pods -A | grep 'operator'
```

Get the application by running this command:

```console
helm list -f vmoperator -n NAMESPACE
```

See the history of versions of ``vmoperator`` application with command.

```console
helm history vmoperator -n NAMESPACE
```

## How to uninstall

Remove application with command.

```console
helm uninstall vmoperator -n NAMESPACE
```

## Validation webhook

  Its possible to use validation of created resources with operator. For now, you need cert-manager to easily certificate management https://cert-manager.io/docs/

```yaml
admissionWebhooks:
  enabled: true
  # what to do in case, when operator not available to validate request.
  certManager:
    # enables cert creation and injection by cert-manager
    enabled: true
```

## Documentation of Helm Chart

Install ``helm-docs`` following the instructions on this [tutorial](../../REQUIREMENTS.md).

Generate docs with ``helm-docs`` command.

```bash
cd charts/victoria-metrics-operator

helm-docs
```

The markdown generation is entirely go template driven. The tool parses metadata from charts and generates a number of sub-templates that can be referenced in a template file (by default ``README.md.gotmpl``). If no template file is provided, the tool has a default internal template that will generate a reasonably formatted README.

## Parameters

The following tables lists the configurable parameters of the chart and their default values.

Change the values according to the need of the environment in ``victoria-metrics-operator/values.yaml`` file.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| admissionWebhooks | object | `{"certManager":{"enabled":false,"issuer":{}},"enabled":true,"enabledCRDValidation":{"vlogs":true,"vmagent":true,"vmalert":true,"vmalertmanager":true,"vmalertmanagerconfig":true,"vmauth":true,"vmcluster":true,"vmrule":true,"vmsingle":true,"vmuser":true},"keepTLSSecret":true,"policy":"Fail","tls":{"caCert":null,"cert":null,"key":null}}` | Configures resource validation |
| admissionWebhooks.certManager | object | `{"enabled":false,"issuer":{}}` | with keys: tls.key, tls.crt, ca.crt |
| admissionWebhooks.certManager.enabled | bool | `false` | Enables cert creation and injection by cert-manager. |
| admissionWebhooks.certManager.issuer | object | `{}` | If needed, provide own issuer. Operator will create self-signed if empty. |
| admissionWebhooks.enabled | bool | `true` | Enables validation webhook. |
| admissionWebhooks.policy | string | `"Fail"` | What to do in case, when operator not available to validate request. |
| affinity | object | `{}` | Pod affinity |
| annotations | object | `{}` | Annotations to be added to the all resources |
| cleanupCRD | bool | `false` | Tells helm to clean up all the vm resources under this release's namespace when uninstalling |
| cleanupImage.pullPolicy | string | `"IfNotPresent"` |  |
| cleanupImage.repository | string | `"bitnami/kubectl"` |  |
| createCRD | bool | `true` | with this option, if you remove this chart, all crd resources will be deleted with it. |
| env | list | `[]` | extra settings for the operator deployment. full list Ref: [https://github.com/VictoriaMetrics/operator/blob/master/vars.MD](https://github.com/VictoriaMetrics/operator/blob/master/vars.MD) |
| envFrom | list | `[]` |  |
| extraArgs | object | `{}` | operator container additional commandline arguments |
| extraContainers | list | `[]` |  |
| extraHostPathMounts | list | `[]` | Additional hostPath mounts |
| extraLabels | object | `{}` | Labels to be added to the all resources |
| extraObjects | list | `[]` | Add extra specs dynamically to this chart |
| extraVolumeMounts | list | `[]` | Extra Volume Mounts for the container |
| extraVolumes | list | `[]` | Extra Volumes for the pod |
| fullnameOverride | string | `""` | Overrides the full name of server component |
| global.cluster.dnsDomain | string | `"cluster.local"` |  |
| global.image.registry | string | `""` |  |
| global.imagePullSecrets | list | `[]` |  |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy |
| image.registry | string | `""` | Image registry |
| image.repository | string | `"victoriametrics/operator"` | Image repository |
| image.tag | string | `""` | Image tag override Chart.AppVersion |
| image.variant | string | `""` |  |
| imagePullSecrets | list | `[]` | Secret to pull images |
| logLevel | string | `"info"` | possible values: info and error. |
| nameOverride | string | `""` | VM operatror deployment name override |
| nodeSelector | object | `{}` | Pod's node selector. Ref: [https://kubernetes.io/docs/user-guide/node-selection/](https://kubernetes.io/docs/user-guide/node-selection/ |
| operator.disable_prometheus_converter | bool | `false` | By default, operator converts prometheus-operator objects. |
| operator.enable_converter_ownership | bool | `false` | Enables ownership reference for converted prometheus-operator objects, it will remove corresponding victoria-metrics objects in case of deletion prometheus one. |
| operator.prometheus_converter_add_argocd_ignore_annotations | bool | `false` | Compare-options and sync-options for prometheus objects converted by operator for properly use with ArgoCD |
| operator.useCustomConfigReloader | bool | `false` | Enables custom config-reloader, bundled with operator. It should reduce  vmagent and vmauth config sync-time and make it predictable. |
| podDisruptionBudget.enabled | bool | `false` |  |
| podDisruptionBudget.labels | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| probe.liveness.failureThreshold | int | `3` |  |
| probe.liveness.initialDelaySeconds | int | `5` |  |
| probe.liveness.periodSeconds | int | `15` |  |
| probe.liveness.tcpSocket.port | string | `"probe"` |  |
| probe.liveness.timeoutSeconds | int | `5` |  |
| probe.readiness.failureThreshold | int | `3` |  |
| probe.readiness.httpGet.path | string | `"{{ include \"vm.probe.http.path\" . }}"` |  |
| probe.readiness.httpGet.port | string | `"probe"` |  |
| probe.readiness.httpGet.scheme | string | `"{{ include \"vm.probe.http.scheme\" . }}"` |  |
| probe.readiness.initialDelaySeconds | int | `5` |  |
| probe.readiness.periodSeconds | int | `15` |  |
| probe.readiness.timeoutSeconds | int | `5` |  |
| probe.startup | object | `{}` |  |
| rbac.aggregatedClusterRoles | object | `{"enabled":true,"labels":{"admin":{"rbac.authorization.k8s.io/aggregate-to-admin":"true"},"view":{"rbac.authorization.k8s.io/aggregate-to-view":"true"}}}` | create aggregated clusterRoles for CRD readonly and admin permissions |
| rbac.aggregatedClusterRoles.labels | object | `{"admin":{"rbac.authorization.k8s.io/aggregate-to-admin":"true"},"view":{"rbac.authorization.k8s.io/aggregate-to-view":"true"}}` | labels attached to according clusterRole |
| rbac.create | bool | `true` | Specifies whether the RBAC resources should be created |
| replicaCount | int | `1` |  |
| resources | object | `{}` | Resource object |
| securityContext | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.clusterIP | string | `""` |  |
| service.externalIPs | string | `""` |  |
| service.externalTrafficPolicy | string | `""` |  |
| service.healthCheckNodePort | string | `""` |  |
| service.ipFamilies | list | `[]` |  |
| service.ipFamilyPolicy | string | `""` |  |
| service.labels | object | `{}` |  |
| service.loadBalancerIP | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceMonitor | object | `{"annotations":{},"basicAuth":{},"enabled":false,"extraLabels":{},"interval":"","relabelings":[],"scheme":"","scrapeTimeout":"","tlsConfig":{}}` | configures monitoring with serviceScrape. VMServiceScrape must be pre-installed |
| tolerations | list | `[]` | Array of tolerations object. Ref: [https://kubernetes.io/docs/concepts/configuration/assign-pod-node/](https://kubernetes.io/docs/concepts/configuration/assign-pod-node/) |
| topologySpreadConstraints | list | `[]` | Pod Topology Spread Constraints. Ref: [https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) |
| watchNamespace | string | `""` |  |
