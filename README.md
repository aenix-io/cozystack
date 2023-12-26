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
EOT
```

Run [talos-bootstrap](https://github.com/aenix-io/talos-bootstrap/) to deploy cluster


### Install Cozystack

Install cozystack system components:

```
export KUBECONFIG=${PWD}/kubeconfig
for i in \
  cilium \
  kubeovn \
  fluxcd \
  cert-manager \
  victoria-metrics-operator \
  monitoring \
  kubeapps \
  kubevirt \
  metallb \
  grafana-operator \
  mariadb-operator \
  postgres-operator \
  rabbitmq-operator \
  piraeus-operator \
  redis-operator \
  linstor \
  telepresence \
  ingress-nginx \
do
  make -C "system/$i" apply
done
```

Check status of deployments:
```
helm ls -A
# NAME                            NAMESPACE                       REVISION        UPDATED                                 STATUS          CHART                 APP VERSION
# cert-manager                    cozy-cert-manager               1               2023-12-26 17:59:53.360566717 +0000 UTC deployed        cozystack-0.0.0
# cilium                          cozy-cilium                     1               2023-12-26 17:58:13.257363562 +0000 UTC deployed        cozystack-0.0.0
# grafana-operator                cozy-grafana-operator           1               2023-12-26 18:00:27.040639056 +0000 UTC deployed        cozystack-0.0.0
# ingress-nginx                   cozy-ingress-nginx              1               2023-12-26 18:00:47.628341874 +0000 UTC deployed        cozystack-0.0.0
# kubeapps                        cozy-kubeapps                   1               2023-12-26 18:00:17.955946393 +0000 UTC deployed        cozystack-0.0.0
# kubeapps                        cozy-fluxcd                     1               2023-12-26 17:59:43.916449245 +0000 UTC deployed        cozystack-0.0.0
# kubevirt                        cozy-kubevirt                   1               2023-12-26 18:00:20.417334537 +0000 UTC deployed        cozystack-0.0.0
# linstor                         cozy-linstor                    1               2023-12-26 18:00:40.858381945 +0000 UTC deployed        cozystack-0.0.0
# mariadb-operator                cozy-mariadb-operator           1               2023-12-26 18:00:30.598967718 +0000 UTC deployed        cozystack-0.0.0
# metallb                         cozy-metallb                    1               2023-12-26 18:00:24.001145931 +0000 UTC deployed        cozystack-0.0.0
# monitoring                      cozy-monitoring                 1               2023-12-26 18:00:15.97255153 +0000 UTC  deployed        cozystack-0.0.0
# piraeus-operator                cozy-linstor                    1               2023-12-26 18:00:37.914192412 +0000 UTC deployed        cozystack-0.0.0
# postgres-operator               cozy-postgres-operator          1               2023-12-26 18:00:33.457111594 +0000 UTC deployed        cozystack-0.0.0
# rabbitmq-operator               cozy-rabbitmq-operator          1               2023-12-26 18:00:35.830732116 +0000 UTC deployed        cozystack-0.0.0
# redis-operator                  cozy-redis-operator             1               2023-12-26 18:00:40.151932075 +0000 UTC deployed        cozystack-0.0.0
# traffic-manager                 cozy-telepresence               1               2023-12-26 18:00:46.364632248 +0000 UTC deployed        cozystack-0.0.0
# victoria-metrics-operator       cozy-victoria-metrics-operator  1               2023-12-26 18:00:13.636953818 +0000 UTC deployed        cozystack-0.0.0
```
