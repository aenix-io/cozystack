# Cozystack

## Quick Start

### Netboot server

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

```
docker ps
# CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS     NAMES
# e5e1323c014a   quay.io/poseidon/dnsmasq            "/usr/sbin/dnsmasq -…"   2 seconds ago    Up 1 second               dnsmasq
# d256b46ab9e9   quay.io/poseidon/matchbox:v0.10.0   "/matchbox -address=…"   43 seconds ago   Up 42 seconds             matchbox
```


