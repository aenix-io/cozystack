FROM ubuntu:22.04 as guestfish

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get -y install \
     libguestfs-tools \
     linux-image-generic \
     make \
     bash-completion \
 && apt-get clean

WORKDIR /build

FROM guestfish as builder

RUN wget -O image.img https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

RUN qemu-img resize image.img 5G \
 && eval "$(guestfish --listen --network)" \
 && guestfish --remote add-drive image.img \
 && guestfish --remote run \
 && guestfish --remote mount /dev/sda1 / \
 && guestfish --remote command "growpart /dev/sda 1 --verbose" \
 && guestfish --remote command "resize2fs /dev/sda1" \
# docker repo
 && guestfish --remote sh "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg" \
 && guestfish --remote sh 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list' \
# kubernetes repo
 && guestfish --remote sh "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg" \
 && guestfish --remote sh "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list" \
# install containerd
 && guestfish --remote command "apt-get update -y" \
 && guestfish --remote command "apt-get install -y containerd.io" \
# configure containerd
 && guestfish --remote command "mkdir -p /etc/containerd" \
 && guestfish --remote sh "containerd config default | tee /etc/containerd/config.toml" \
 && guestfish --remote command "sed -i '/SystemdCgroup/ s/=.*/= true/' /etc/containerd/config.toml" \
# install kubernetes
 && guestfish --remote command "apt-get install -y kubelet kubeadm" \
# clean apt cache
 && guestfish --remote sh 'apt-get clean && rm -rf /var/lib/apt/lists/*' \
# write system configuration
 && guestfish --remote sh 'printf "%s\n" net.bridge.bridge-nf-call-iptables=1 net.bridge.bridge-nf-call-ip6tables=1 net.ipv4.ip_forward=1 net.ipv6.conf.all.forwarding=1 net.ipv6.conf.all.disable_ipv6=0 net.ipv4.tcp_congestion_control=bbr vm.overcommit_memory=1 kernel.panic=10 kernel.panic_on_oops=1 fs.inotify.max_user_instances=8192 fs.inotify.max_user_watches=524288 | tee > /etc/sysctl.d/kubernetes.conf' \
 && guestfish --remote sh 'printf "%s\n" overlay br_netfilter | tee /etc/modules-load.d/kubernetes.conf' \
 && guestfish --remote sh "rm -f /etc/resolv.conf && ln -s ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf" \
# umount all and exit
 && guestfish --remote umount-all \
 && guestfish --remote exit

FROM scratch
COPY --from=builder /build/image.img /disk/image.qcow2
