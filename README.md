# Cozystack

## Quick Start

Install dependicies:

- `docker`
- `talosctl`
- `dialog`
- `nmap`
- `make`
- `yq`
- `kubectl`
- `helm`

### Netboot server

Write configuration:

```
mkdir -p matchbox/assets matchbox/groups matchbox/profiles

wget -O matchbox/assets/initramfs.xz \
  https://github.com/siderolabs/talos/releases/download/v1.6.0/initramfs-amd64.xz
wget -O matchbox/assets/vmlinuz \
  https://github.com/siderolabs/talos/releases/download/v1.6.0/vmlinuz-amd64


cat > matchbox/groups/default.json <<EOT
{
  "id": "default",
  "name": "default",
  "profile": "default"
}
EOT

cat > matchbox/profiles/default.json <<EOT
{
  "id": "default",
  "name": "default",
  "boot": {
    "kernel": "/assets/vmlinuz",
    "initrd": ["/assets/initramfs.xz"],
    "args": [
      "initrd=initramfs.xz",
      "init_on_alloc=1",
      "slab_nomerge",
      "pti=on",
      "console=tty0",
      "console=ttyS0",
      "printk.devkmsg=on",
      "talos.platform=metal"
    ]
  }
}
EOT
```

Start matchbox:

```
sudo docker run --name=matchbox -d --net=host -v ${PWD}/matchbox:/var/lib/matchbox:Z quay.io/poseidon/matchbox:v0.10.0 \
  -address=:8080 \
  -log-level=debug
```


Start DHCP-Server:
```
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
  --dhcp-boot=tag:ipxe,http://192.168.100.250:8080/boot.ipxe \
  --address=/matchbox.example.com/192.168.1.2 \
  --log-queries \
  --log-dhcp
```

Check status of containers:
```
docker ps
# CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS     NAMES
# e5e1323c014a   quay.io/poseidon/dnsmasq            "/usr/sbin/dnsmasq -…"   2 seconds ago    Up 1 second               dnsmasq
# d256b46ab9e9   quay.io/poseidon/matchbox:v0.10.0   "/matchbox -address=…"   43 seconds ago   Up 42 seconds             matchbox
```

### Bootstrap cluster

Write configuration for Cozystack:

```yaml
cat > patch.yaml <<EOT
machine:
  kubelet:
    nodeIP:
      validSubnets:
      - 192.168.100.0/24
  kernel:
    modules:
    - name: drbd
      parameters:
        - usermode_helper=disabled
    - name: openvswitch
  install:
    image: ghcr.io/siderolabs/installer:v1.6.0
    extensions:
    - image: ghcr.io/siderolabs/drbd:9.2.6-v1.6.0

cluster:
  network:
    cni:
      name: none
    podSubnets:
    - 10.244.0.0/16
    serviceSubnets:
    - 10.96.0.0/16

  allowSchedulingOnControlPlanes: true
  controllerManager:
    extraArgs:
      bind-address: 0.0.0.0
  scheduler:
    extraArgs:
      bind-address: 0.0.0.0
  proxy:
    disabled: true
  discovery:
    enabled: false
  etcd:
    advertisedSubnets:
    - 192.168.100.0/24

  inlineManifests:
  - name: cozystack
    contents: |
      apiVersion: v1
      kind: ConfigMap
      metadata:
        name: cozystack
        namespace: cozy-system
      data:
        ipv4-pod-cidr: "10.244.0.0/16"
        ipv4-pod-gateway: "10.244.0.1"
        ipv4-svc-cidr: "10.96.0.0/16"
        ipv4-join-cidr: "100.64.0.0/16"
EOT
```

Run [talos-bootstrap](https://github.com/aenix-io/talos-bootstrap/) to deploy cluster


### Install Cozystack

Install cozystack system components:

```
kubectl apply -f cozystack-installer.yaml
```

### Chart Install Responsibilities

#### core/installer:
  - **system/cilium** [helm]
  - **system/kubeovn** [helm]
  - **system/fluxcd** [helm]
  - **core/platform** [kubectl]

#### core/platform:
  - **system/\*** [fluxcd]
