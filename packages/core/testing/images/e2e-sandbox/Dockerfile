FROM ubuntu:22.04

ARG KUBECTL_VERSION=1.31.0
ARG TALOSCTL_VERSION=1.7.6
ARG HELM_VERSION=3.15.4

RUN apt-get update
RUN apt-get -y install genisoimage qemu-kvm qemu-utils iproute2 iptables wget xz-utils netcat curl
RUN curl -LO "https://github.com/siderolabs/talos/releases/download/v${TALOSCTL_VERSION}/talosctl-linux-amd64" \
 && chmod +x talosctl-linux-amd64 \
 && mv talosctl-linux-amd64 /usr/local/bin/talosctl
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
 && chmod +x kubectl \
 && mv kubectl /usr/local/bin/kubectl
RUN curl -sSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -s - --version "v${HELM_VERSION}"
