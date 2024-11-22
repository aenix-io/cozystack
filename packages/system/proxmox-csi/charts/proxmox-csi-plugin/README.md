# proxmox-csi-plugin

![Version: 0.2.13](https://img.shields.io/badge/Version-0.2.13-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.8.2](https://img.shields.io/badge/AppVersion-v0.8.2-informational?style=flat-square)

Container Storage Interface plugin for Proxmox

The Container Storage Interface (CSI) plugin is a specification designed to standardize the way container orchestration systems like Kubernetes, interact with different storage systems. The CSI plugin abstracts the underlying storage, enabling the seamless integration of different storage solutions (such as local block devices, file systems, or cloud-based storage) with containerized applications.

This plugin allows Kubernetes to use `Proxmox VE` storage as a persistent storage solution for stateful applications.
Supported storage types:
- Directory
- LVM
- LVM-thin
- ZFS
- NFS
- Ceph

**Homepage:** <https://github.com/sergelogvinov/proxmox-csi-plugin>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| sergelogvinov |  | <https://github.com/sergelogvinov> |

## Source Code

* <https://github.com/sergelogvinov/proxmox-csi-plugin>

## Proxmox permissions

```shell
# Create role CSI
pveum role add CSI -privs "VM.Audit VM.Config.Disk Datastore.Allocate Datastore.AllocateSpace Datastore.Audit"
# Create user and grant permissions
pveum user add kubernetes-csi@pve
pveum aclmod / -user kubernetes-csi@pve -role CSI
pveum user token add kubernetes-csi@pve csi -privsep 0
```

## Helm values example

```yaml
# proxmox-csi.yaml

config:
  clusters:
    - url: https://cluster-api-1.exmple.com:8006/api2/json
      insecure: false
      token_id: "kubernetes-csi@pve!csi"
      token_secret: "key"
      region: cluster-1

# Deploy Node CSI driver only on proxmox nodes
node:
  nodeSelector:
    # It will work only with Talos CCM, remove it overwise
    node.cloudprovider.kubernetes.io/platform: nocloud
  tolerations:
    - operator: Exists

# Deploy CSI controller only on control-plane nodes
nodeSelector:
  node-role.kubernetes.io/control-plane: ""
tolerations:
  - key: node-role.kubernetes.io/control-plane
    effect: NoSchedule

# Define storage classes
# See https://pve.proxmox.com/wiki/Storage
storageClass:
  - name: proxmox-data-xfs
    storage: data
    reclaimPolicy: Delete
    fstype: xfs
  - name: proxmox-data
    storage: data
    reclaimPolicy: Delete
    fstype: ext4
    cache: writethrough
```

## Deploy

```shell
# Prepare namespace
kubectl create ns csi-proxmox
kubectl label ns csi-proxmox pod-security.kubernetes.io/enforce=privileged
# Install Proxmox CSI plugin
helm upgrade -i --namespace=csi-proxmox -f proxmox-csi.yaml \
    proxmox-csi-plugin oci://ghcr.io/sergelogvinov/charts/proxmox-csi-plugin
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` |  |
| imagePullSecrets | list | `[]` |  |
| nameOverride | string | `""` |  |
| fullnameOverride | string | `""` |  |
| createNamespace | bool | `false` | Create namespace. Very useful when using helm template. |
| priorityClassName | string | `"system-cluster-critical"` | Controller pods priorityClassName. |
| serviceAccount | object | `{"annotations":{},"create":true,"name":""}` | Pods Service Account. ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/ |
| provisionerName | string | `"csi.proxmox.sinextra.dev"` | CSI Driver provisioner name. Currently, cannot be customized. |
| clusterID | string | `"kubernetes"` | Cluster name. Currently, cannot be customized. |
| logVerbosityLevel | int | `5` | Log verbosity level. See https://github.com/kubernetes/community/blob/master/contributors/devel/sig-instrumentation/logging.md for description of individual verbosity levels. |
| timeout | string | `"3m"` | Connection timeout between sidecars. |
| existingConfigSecret | string | `nil` | Proxmox cluster config stored in secrets. |
| existingConfigSecretKey | string | `"config.yaml"` | Proxmox cluster config stored in secrets key. |
| configFile | string | `"/etc/proxmox/config.yaml"` | Proxmox cluster config path. |
| config | object | `{"clusters":[]}` | Proxmox cluster config. |
| storageClass | list | `[]` | Storage class definition. |
| controller.podAnnotations | object | `{}` | Annotations for controller pod. ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| controller.plugin.image | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/sergelogvinov/proxmox-csi-controller","tag":""}` | Controller CSI Driver. |
| controller.plugin.resources | object | `{"requests":{"cpu":"10m","memory":"16Mi"}}` | Controller resource requests and limits. ref: https://kubernetes.io/docs/user-guide/compute-resources/ |
| controller.attacher.image | object | `{"pullPolicy":"IfNotPresent","repository":"registry.k8s.io/sig-storage/csi-attacher","tag":"v4.4.4"}` | CSI Attacher. |
| controller.attacher.resources | object | `{"requests":{"cpu":"10m","memory":"16Mi"}}` | Attacher resource requests and limits. ref: https://kubernetes.io/docs/user-guide/compute-resources/ |
| controller.provisioner.image | object | `{"pullPolicy":"IfNotPresent","repository":"registry.k8s.io/sig-storage/csi-provisioner","tag":"v3.6.4"}` | CSI Provisioner. |
| controller.provisioner.resources | object | `{"requests":{"cpu":"10m","memory":"16Mi"}}` | Provisioner resource requests and limits. ref: https://kubernetes.io/docs/user-guide/compute-resources/ |
| controller.resizer.image | object | `{"pullPolicy":"IfNotPresent","repository":"registry.k8s.io/sig-storage/csi-resizer","tag":"v1.9.4"}` | CSI Resizer. |
| controller.resizer.resources | object | `{"requests":{"cpu":"10m","memory":"16Mi"}}` | Resizer resource requests and limits. ref: https://kubernetes.io/docs/user-guide/compute-resources/ |
| node.plugin.image | object | `{"pullPolicy":"IfNotPresent","repository":"ghcr.io/sergelogvinov/proxmox-csi-node","tag":""}` | Node CSI Driver. |
| node.plugin.resources | object | `{}` | Node CSI Driver resource requests and limits. ref: https://kubernetes.io/docs/user-guide/compute-resources/ |
| node.driverRegistrar.image | object | `{"pullPolicy":"IfNotPresent","repository":"registry.k8s.io/sig-storage/csi-node-driver-registrar","tag":"v2.9.4"}` | Node CSI driver registrar. |
| node.driverRegistrar.resources | object | `{"requests":{"cpu":"10m","memory":"16Mi"}}` | Node registrar resource requests and limits. ref: https://kubernetes.io/docs/user-guide/compute-resources/ |
| node.kubeletDir | string | `"/var/lib/kubelet"` | Location of the /var/lib/kubelet directory as some k8s distribution differ from the standard. |
| node.nodeSelector | object | `{}` | Node labels for node-plugin assignment. ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| node.tolerations | list | `[{"effect":"NoSchedule","key":"node.kubernetes.io/unschedulable","operator":"Exists"},{"effect":"NoSchedule","key":"node.kubernetes.io/disk-pressure","operator":"Exists"}]` | Tolerations for node-plugin assignment. ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| livenessprobe.image | object | `{"pullPolicy":"IfNotPresent","repository":"registry.k8s.io/sig-storage/livenessprobe","tag":"v2.11.0"}` | Common livenessprobe sidecar. |
| livenessprobe.failureThreshold | int | `5` | Failure threshold for livenessProbe |
| livenessprobe.initialDelaySeconds | int | `10` | Initial delay seconds for livenessProbe |
| livenessprobe.timeoutSeconds | int | `10` | Timeout seconds for livenessProbe |
| livenessprobe.periodSeconds | int | `60` | Period seconds for livenessProbe |
| livenessprobe.resources | object | `{"requests":{"cpu":"10m","memory":"16Mi"}}` | Liveness probe resource requests and limits. ref: https://kubernetes.io/docs/user-guide/compute-resources/ |
| initContainers | list | `[]` | Add additional init containers for the CSI controller pods. ref: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/ |
| hostAliases | list | `[]` | hostAliases Deployment pod host aliases ref: https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/ |
| podAnnotations | object | `{}` | Annotations for controller pod. ref: https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/ |
| podSecurityContext | object | `{"fsGroup":65532,"fsGroupChangePolicy":"OnRootMismatch","runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532}` | Controller Security Context. ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod |
| securityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Controller Container Security Context. ref: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod |
| updateStrategy | object | `{"rollingUpdate":{"maxUnavailable":1},"type":"RollingUpdate"}` | Controller deployment update strategy type. ref: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment |
| metrics | object | `{"enabled":false,"port":8080,"type":"annotation"}` | Prometheus metrics |
| metrics.enabled | bool | `false` | Enable Prometheus metrics. |
| metrics.port | int | `8080` | Prometheus metrics port. |
| nodeSelector | object | `{}` | Node labels for controller assignment. ref: https://kubernetes.io/docs/user-guide/node-selection/ |
| tolerations | list | `[]` | Tolerations for controller assignment. ref: https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/ |
| affinity | object | `{}` | Affinity for controller assignment. ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity |
| extraVolumes | list | `[]` | Additional volumes for Pods |
| extraVolumeMounts | list | `[]` |  |
