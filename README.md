![Cozystack](img/cozystack-logo.svg)

[![Open Source](https://img.shields.io/badge/Open-Source-brightgreen)](https://opensource.org/)
[![GPLv3 License](https://img.shields.io/github/license/aenix.io/cozystack)](https://opensource.org/licenses/)
[![Support](https://img.shields.io/badge/$-support-12a0df.svg?style=flat)](https://aenix.io/contact-us/#meet)
[![Active](http://img.shields.io/badge/Status-Active-green.svg)](https://aenix.io/cozystack/)
[![GitHub Release](https://img.shields.io/github/release/aenix.io/cozystack.svg?style=flat)](https://github.com/aenix.io/cozystack)
[![GitHub Commit](https://img.shields.io/github/commit-activity/y/linbit/aenix.io/cozystack)](https://github.com/aenix.io/cozystack) 

# Cozystack

**Cozystack** is an open-source **PaaS platform** for cloud providers.

With Cozystack, you can transform your bunch of servers into an intelligent system with a simple REST API for spawning Kubernetes clusters, Database-as-a-Service, virtual machines, load balancers, HTTP caching services, and other services with ease.

You can use Cozystack to build your own cloud or to provide a cost-effective development environments.  

## Use-Cases

### As a backend for a public cloud

Cozystack positions itself as a kind of framework for building public clouds. The key word here is framework. In this case, it's important to understand that Cozystack is made for cloud providers, not for end users.

Despite having a graphical interface, the current security model does not imply public user access to your management cluster.

Instead, end users get access to their own Kubernetes clusters, can order LoadBalancers and additional services from it, but they have no access and know nothing about your management cluster powered by Cozystack.

Thus, to integrate with your billing system, it's enough to teach your system to go to the management Kubernetes and place a YAML file signifying the service you're interested in. Cozystack will do the rest of the work for you.

![](https://aenix.io/wp-content/uploads/2024/02/Wireframe-1.png)

### As a private cloud for Infrastructure-as-Code

One of the use cases is a self-portal for users within your company, where they can order the service they're interested in or a managed database.

You can implement best GitOps practices, where users will launch their own Kubernetes clusters and databases for their needs with a simple commit of configuration into your infrastructure Git repository.

Thanks to the standardization of the approach to deploying applications, you can expand the platform's capabilities using the functionality of standard Helm charts.

### As a Kubernetes distribution for Bare Metal

We created Cozystack primarily for our own needs, having vast experience in building reliable systems on bare metal infrastructure. This experience led to the formation of a separate boxed product, which is aimed at standardizing and providing a ready-to-use tool for managing your infrastructure.

Currently, Cozystack already solves a huge scope of infrastructure tasks: starting from provisioning bare metal servers, having a ready monitoring system, fast and reliable storage, a network fabric with the possibility of interconnect with your infrastructure, the ability to run virtual machines, databases, and much more right out of the box.

All this makes Cozystack a convenient platform for delivering and launching your application on Bare Metal.

## Screenshot

![](https://aenix.io/wp-content/uploads/2023/12/cozystack1-1.png)

## Core values

### Standardization and unification
All components of the platform are based on open source tools and technologies which are widely known in the industry.

### Collaborate, not compete
If a feature being developed for the platform could be useful to a upstream project, it should be contributed to upstream project, rather than being implemented within the platform.

### API-first
Cozystack is based on Kubernetes and involves close interaction with its API. We don't aim to completely hide the all elements behind a pretty UI or any sort of customizations; instead, we provide a standard interface and teach users how to work with basic primitives. The web interface is used solely for deploying applications and quickly diving into basic concepts of platform.

## Quick Start

### Preapre infrastructure


![](https://aenix.io/wp-content/uploads/2024/02/Wireframe-2.png)

You need 3 physical servers or VMs with nested virtualisation:

```
4 cores
8-16 RAM
CPU model: host
HDD1: 32 GB
HDD2: 100GB (raw)
```

And one management VM or physical server connected to the same network.
Any Linux system installed on it (eg. Ubuntu should be enough)

**Note:** The VM should support `x86-64-v2` architecture, the most probably you can achieve this by setting cpu model to `host`

#### Install dependicies:

- `docker`
- `talosctl`
- `dialog`
- `nmap`
- `make`
- `yq`
- `kubectl`
- `helm`

### Netboot server

Start matchbox with prebuilt Talos image for Cozystack:

```bash
sudo docker run --name=matchbox -d --net=host ghcr.io/aenix-io/cozystack/matchbox:v0.0.1 \
  -address=:8080 \
  -log-level=debug
```

Start DHCP-Server:
```bash
sudo docker run --name=dnsmasq -d --cap-add=NET_ADMIN --net=host quay.io/poseidon/dnsmasq \
  -d -q -p0 \
  --dhcp-range=192.168.100.3,192.168.100.254 \
  --dhcp-option=option:router,192.168.100.1 \
  --enable-tftp \
  --tftp-root=/var/lib/tftpboot \
  --dhcp-match=set:bios,option:client-arch,0 \
  --dhcp-boot=tag:bios,undionly.kpxe \
  --dhcp-match=set:efi32,option:client-arch,6 \
  --dhcp-boot=tag:efi32,ipxe.efi \
  --dhcp-match=set:efibc,option:client-arch,7 \
  --dhcp-boot=tag:efibc,ipxe.efi \
  --dhcp-match=set:efi64,option:client-arch,9 \
  --dhcp-boot=tag:efi64,ipxe.efi \
  --dhcp-userclass=set:ipxe,iPXE \
  --dhcp-boot=tag:ipxe,http://192.168.100.254:8080/boot.ipxe \
  --log-queries \
  --log-dhcp
```

Where:
- `192.168.100.3,192.168.100.254` range to allocate IPs from
- `192.168.100.1` your gateway
- `192.168.100.254` is address of your management server

Check status of containers:

```
docker ps
```

example output:

```console
CONTAINER ID   IMAGE                                        COMMAND                  CREATED          STATUS          PORTS     NAMES
22044f26f74d   quay.io/poseidon/dnsmasq                     "/usr/sbin/dnsmasq -…"   6 seconds ago    Up 5 seconds              dnsmasq
231ad81ff9e0   ghcr.io/aenix-io/cozystack/matchbox:v0.0.1   "/matchbox -address=…"   58 seconds ago   Up 57 seconds             matchbox
```

### Bootstrap cluster

Write configuration for Cozystack:

```yaml
cat > patch.yaml <<\EOT
machine:
  kubelet:
    nodeIP:
      validSubnets:
      - 192.168.100.0/24
  kernel:
    modules:
    - name: openvswitch
    - name: drbd
      parameters:
        - usermode_helper=disabled
    - name: zfs
  install:
    image: ghcr.io/aenix-io/cozystack/talos:v1.6.4
  files:
  - content: |
      [plugins]
        [plugins."io.containerd.grpc.v1.cri"]
          device_ownership_from_security_context = true
    path: /etc/cri/conf.d/20-customization.part
    op: create

cluster:
  network:
    cni:
      name: none
    podSubnets:
    - 10.244.0.0/16
    serviceSubnets:
    - 10.96.0.0/16
EOT

cat > patch-controlplane.yaml <<\EOT
cluster:
  allowSchedulingOnControlPlanes: true
  controllerManager:
    extraArgs:
      bind-address: 0.0.0.0
  scheduler:
    extraArgs:
      bind-address: 0.0.0.0
  apiServer:
    certSANs:
    - 127.0.0.1
  proxy:
    disabled: true
  discovery:
    enabled: false
  etcd:
    advertisedSubnets:
    - 192.168.100.0/24
EOT
```

Run [talos-bootstrap](https://github.com/aenix-io/talos-bootstrap/) to deploy cluster:

```bash
talos-bootstrap install
```

Save admin kubeconfig to access your Kubernetes cluster:
```bash
cp -i kubeconfig ~/.kube/config
```

Check connection:
```bash
kubectl get ns
```

example output:
```console
NAME              STATUS   AGE
default           Active   7m56s
kube-node-lease   Active   7m56s
kube-public       Active   7m56s
kube-system       Active   7m56s
```

### Install Cozystack


write config for cozystack:

**Note:** please make sure that you written the same setting specified in `patch.yaml` and `patch-controlplane.yaml` files.

```yaml
cat > cozystack-config.yaml <<\EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: cozystack
  namespace: cozy-system
data:
  cluster-name: "cozystack"
  ipv4-pod-cidr: "10.244.0.0/16"
  ipv4-pod-gateway: "10.244.0.1"
  ipv4-svc-cidr: "10.96.0.0/16"
  ipv4-join-cidr: "100.64.0.0/16"
EOT
```

Create namesapce and install Cozystack system components:

```bash
kubectl create ns cozy-system
kubectl apply -f cozystack-config.yaml
kubectl apply -f manifests/cozystack-installer.yaml
```

(optional) You can check logs of installer:
```bash
kubectl logs -n cozy-system deploy/cozystack
```

Wait for a while, then check the status of installation:
```bash
kubectl get hr -A
```

Wait until all releases become to `Ready` state:
```console
NAMESPACE                        NAME                        AGE     READY   STATUS
cozy-cert-manager                cert-manager                2m54s   True    Release reconciliation succeeded
cozy-cert-manager                cert-manager-issuers        2m54s   True    Release reconciliation succeeded
cozy-cilium                      cilium                      2m54s   True    Release reconciliation succeeded
cozy-cluster-api                 capi-operator               2m53s   True    Release reconciliation succeeded
cozy-cluster-api                 capi-providers              2m53s   True    Release reconciliation succeeded
cozy-dashboard                   dashboard                   2m53s   True    Release reconciliation succeeded
cozy-fluxcd                      cozy-fluxcd                 2m54s   True    Release reconciliation succeeded
cozy-grafana-operator            grafana-operator            2m53s   True    Release reconciliation succeeded
cozy-kamaji                      kamaji                      2m53s   True    Release reconciliation succeeded
cozy-kubeovn                     kubeovn                     2m54s   True    Release reconciliation succeeded
cozy-kubevirt-cdi                kubevirt-cdi                2m54s   True    Release reconciliation succeeded
cozy-kubevirt-cdi                kubevirt-cdi-operator       2m54s   True    Release reconciliation succeeded
cozy-kubevirt                    kubevirt                    2m54s   True    Release reconciliation succeeded
cozy-kubevirt                    kubevirt-operator           2m54s   True    Release reconciliation succeeded
cozy-linstor                     linstor                     2m53s   True    Release reconciliation succeeded
cozy-linstor                     piraeus-operator            2m53s   True    Release reconciliation succeeded
cozy-mariadb-operator            mariadb-operator            2m53s   True    Release reconciliation succeeded
cozy-metallb                     metallb                     2m53s   True    Release reconciliation succeeded
cozy-monitoring                  monitoring                  2m54s   True    Release reconciliation succeeded
cozy-postgres-operator           postgres-operator           2m53s   True    Release reconciliation succeeded
cozy-rabbitmq-operator           rabbitmq-operator           2m53s   True    Release reconciliation succeeded
cozy-redis-operator              redis-operator              2m53s   True    Release reconciliation succeeded
cozy-telepresence                telepresence                2m53s   True    Release reconciliation succeeded
cozy-victoria-metrics-operator   victoria-metrics-operator   2m54s   True    Release reconciliation succeeded
tenant-root                      tenant-root                 2m54s   True    Release reconciliation succeeded
```

#### Configure Storage

Setup alias to access LINSTOR:
```bash
alias linstor='kubectl exec -n cozy-linstor deploy/linstor-controller -- linstor'
```

list your nodes
```bash
linstor node list
```

example output:

```console
+-------------------------------------------------------+
| Node | NodeType  | Addresses                 | State  |
|=======================================================|
| srv1 | SATELLITE | 192.168.100.11:3367 (SSL) | Online |
| srv2 | SATELLITE | 192.168.100.12:3367 (SSL) | Online |
| srv3 | SATELLITE | 192.168.100.13:3367 (SSL) | Online |
+-------------------------------------------------------+
```

list empty devices:

```bash
linstor physical-storage list
```

example output:
```console
+-------------------------------------------+
| Size        | Rotational | Nodes          |
|===========================================|
| 34359738368 | True       | srv3[/dev/sdb] |
|             |            | srv1[/dev/sdb] |
|             |            | srv2[/dev/sdb] |
+-------------------------------------------+
```


create storage pools:

```bash
linstor ps cdp lvm srv1 /dev/sdb --pool-name data --storage-pool data
linstor ps cdp lvm srv2 /dev/sdb --pool-name data --storage-pool data
linstor ps cdp lvm srv3 /dev/sdb --pool-name data --storage-pool data
```

list storage pools:

```bash
linstor sp l
```

example output:

```console
+-------------------------------------------------------------------------------------------------------------------------------------+
| StoragePool          | Node | Driver   | PoolName | FreeCapacity | TotalCapacity | CanSnapshots | State | SharedName                |
|=====================================================================================================================================|
| DfltDisklessStorPool | srv1 | DISKLESS |          |              |               | False        | Ok    | srv1;DfltDisklessStorPool |
| DfltDisklessStorPool | srv2 | DISKLESS |          |              |               | False        | Ok    | srv2;DfltDisklessStorPool |
| DfltDisklessStorPool | srv3 | DISKLESS |          |              |               | False        | Ok    | srv3;DfltDisklessStorPool |
| data                 | srv1 | LVM      | data     |   100.00 GiB |    100.00 GiB | False        | Ok    | srv1;data                 |
| data                 | srv2 | LVM      | data     |   100.00 GiB |    100.00 GiB | False        | Ok    | srv2;data                 |
| data                 | srv3 | LVM      | data     |   100.00 GiB |    100.00 GiB | False        | Ok    | srv3;data                 |
+-------------------------------------------------------------------------------------------------------------------------------------+
```


Create default storage classes:
```yaml
kubectl create -f- <<EOT
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local
  annotations:
    storageclass.kubernetes.io/is-default-class: "true"
provisioner: linstor.csi.linbit.com
parameters:
  linstor.csi.linbit.com/storagePool: "data"
  linstor.csi.linbit.com/layerList: "storage"
  linstor.csi.linbit.com/allowRemoteVolumeAccess: "false"
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: replicated
provisioner: linstor.csi.linbit.com
parameters:
  linstor.csi.linbit.com/storagePool: "data"
  linstor.csi.linbit.com/autoPlace: "3"
  linstor.csi.linbit.com/layerList: "drbd storage"
  linstor.csi.linbit.com/allowRemoteVolumeAccess: "true"
  property.linstor.csi.linbit.com/DrbdOptions/auto-quorum: suspend-io
  property.linstor.csi.linbit.com/DrbdOptions/Resource/on-no-data-accessible: suspend-io
  property.linstor.csi.linbit.com/DrbdOptions/Resource/on-suspended-primary-outdated: force-secondary
  property.linstor.csi.linbit.com/DrbdOptions/Net/rr-conflict: retry-connect
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOT
```

list storageclasses:

```bash
kubectl get storageclasses
```

example output:
```console
NAME              PROVISIONER              RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local (default)   linstor.csi.linbit.com   Delete          WaitForFirstConsumer   true                   11m
replicated        linstor.csi.linbit.com   Delete          WaitForFirstConsumer   true                   11m
```

#### Configure Networking interconnection

To access your services select the range of unused IPs, eg. `192.168.100.200-192.168.100.250`

**Note:** These IPs should be from the same network as nodes or they should have all necessary routes for them.

Configure MetalLB to use and announce this range:
```yaml
kubectl create -f- <<EOT
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: cozystack
  namespace: cozy-metallb
spec:
  ipAddressPools:
  - cozy-public
---
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: cozystack
  namespace: cozy-metallb
spec:
  addresses:
  - 192.168.100.200-192.168.100.250
  autoAssign: true
  avoidBuggyIPs: false
EOT
```

#### Setup basic applications

Get token from `tenant-root`:
```bash
kubectl get secret -n tenant-root tenant-root -o go-template='{{ printf "%s\n" (index .data "token" | base64decode) }}'
```

Enable port forward to cozy-dashboard:
```bash
kubectl port-forward -n cozy-dashboard svc/dashboard 8080:80
```

Open: http://localhost:8080/

- Select `tenant-root`
- Click `Upgrade` button
- Write a domain into `host` which you wish to use as parent domain for all deployed applications
  **Note:**
    - if you have no domain yet, you can use `192.168.100.200.nip.io` where `192.168.100.200` is a first IP address in your network addresses range.
    - alternatively you can leave the default value, however you'll be need to modify your `/etc/hosts` every time you want to access specific application.
- Set `etcd`, `monitoring` and `ingress` to enabled position
- Click Deploy


Check persistent volumes provisioned:

```bash
kubectl get pvc -n tenant-root
```

example output:
```console
NAME                                     STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
data-etcd-0                              Bound    pvc-bfc844a6-4253-411c-a2cd-94fb5a98b1ce   10Gi       RWO            local          <unset>                 28m
data-etcd-1                              Bound    pvc-b198f493-fb47-431c-a7aa-3befcf38a7d2   10Gi       RWO            local          <unset>                 28m
data-etcd-2                              Bound    pvc-554fa8eb-d99b-4088-9dc9-2b7442bcfe1c   10Gi       RWO            local          <unset>                 28m
grafana-db-1                             Bound    pvc-47a3d4a3-4e81-4724-8efa-eb94ee9e29b4   10Gi       RWO            local          <unset>                 28m
grafana-db-2                             Bound    pvc-e1188950-cfa8-446a-865d-a30abfb5a018   10Gi       RWO            local          <unset>                 28m
vmselect-cachedir-vmselect-longterm-0    Bound    pvc-13c5822b-744d-4df3-b9b9-623dd0cad414   2Gi        RWO            local          <unset>                 28m
vmselect-cachedir-vmselect-longterm-1    Bound    pvc-d7b707cd-d5ec-45d7-b60c-b8edb49993b3   2Gi        RWO            local          <unset>                 28m
vmselect-cachedir-vmselect-shortterm-0   Bound    pvc-dbe7d9eb-a2ad-4b38-bef6-672c44f16188   2Gi        RWO            local          <unset>                 28m
vmselect-cachedir-vmselect-shortterm-1   Bound    pvc-a6472fbe-7f7b-4a7e-b6e1-80f8b26d1e44   2Gi        RWO            local          <unset>                 28m
vmstorage-db-vmstorage-longterm-0        Bound    pvc-0b348bd9-4371-439b-b3e8-9e5b68df6632   10Gi       RWO            local          <unset>                 28m
vmstorage-db-vmstorage-longterm-1        Bound    pvc-e217d1e4-b467-4487-abb7-585410c96e54   10Gi       RWO            local          <unset>                 28m
vmstorage-db-vmstorage-shortterm-0       Bound    pvc-b891172e-011c-4a6a-936c-cda4e04ad99f   10Gi       RWO            local          <unset>                 28m
vmstorage-db-vmstorage-shortterm-1       Bound    pvc-d8d9da02-523e-4ec7-809a-bfc3b8f46f72   10Gi       RWO            local          <unset>                 28m
```

Check all pods are running:


```bash
kubectl get pod -n tenant-root
```

example output:
```console
NAME                                           READY   STATUS       RESTARTS   AGE
etcd-0                                         1/1     Running      0          90s
etcd-1                                         1/1     Running      0          90s
etcd-2                                         1/1     Running      0          90s
grafana-deployment-74b5656d6-cp6x4             1/1     Running      0          97s
grafana-deployment-74b5656d6-wflhs             1/1     Running      0          97s
root-ingress-controller-6ccf55bc6d-8dsb7       2/2     Running      0          97s
root-ingress-controller-6ccf55bc6d-xnb8w       2/2     Running      0          96s
root-ingress-defaultbackend-686bcbbd6c-hl6sb   1/1     Running      0          94s
vmalert-vmalert-644986d5c-dv9dm                2/2     Running      0          92s
vmalertmanager-alertmanager-0                  2/2     Running      0          87s
vmalertmanager-alertmanager-1                  2/2     Running      0          84s
vminsert-longterm-75789465f-7sv5m              1/1     Running      0          86s
vminsert-longterm-75789465f-st2vf              1/1     Running      0          88s
vminsert-shortterm-78456f8fd9-2wmgz            1/1     Running      0          82s
vminsert-shortterm-78456f8fd9-mc2fp            1/1     Running      0          84s
vmselect-longterm-0                            1/1     Running      0          75s
vmselect-longterm-1                            1/1     Running      0          73s
vmselect-shortterm-0                           1/1     Running      0          71s
vmselect-shortterm-1                           1/1     Running      0          70s
vmstorage-longterm-0                           1/1     Running      0          67s
vmstorage-longterm-1                           1/1     Running      0          70s
vmstorage-shortterm-0                          1/1     Running      0          69s
vmstorage-shortterm-1                          1/1     Running      0          68s
```

Now you can get public IP of ingress controller:
```
kubectl get svc -n tenant-root root-ingress-controller
```

example output:
```console
NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)                      AGE
root-ingress-controller   LoadBalancer   10.96.101.234   192.168.100.200   80:31879/TCP,443:31262/TCP   49s
```

Use `grafana.example.org` (under 192.168.100.200) to access system monitoring, where `example.org` is your domain specified for `tenant-root`

- login: `admin`
- password:

```bash
kubectl get secret -n tenant-root grafana-admin-password -o go-template='{{ printf "%s\n" (index .data "password" | base64decode) }}'
```
