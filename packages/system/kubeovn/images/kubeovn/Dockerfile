# syntax = docker/dockerfile:experimental

ARG VERSION=v1.12.20
ARG BASE_TAG=$VERSION

FROM golang:1.22-bookworm as builder

ARG COMMIT_REF=ed16ce5

WORKDIR /source

RUN wget -O- https://github.com/kubeovn/kube-ovn/archive/${COMMIT_REF}.tar.gz | tar xzf - --strip-components=1
RUN sed -i 's|-z now|-z now -static|' Makefile
RUN make build-go

WORKDIR /source/dist/images

# imported from https://github.com/kubeovn/kube-ovn/blob/master/dist/images/Dockerfile
FROM kubeovn/kube-ovn-base:$BASE_TAG as setcap

COPY --from=builder /source/dist/images/*.sh /kube-ovn/
COPY --from=builder /source/dist/images/kubectl-ko /kube-ovn/kubectl-ko
COPY --from=builder /source/dist/images/01-kube-ovn.conflist /kube-ovn/01-kube-ovn.conflist

COPY --from=builder /source/dist/images/kube-ovn /kube-ovn/kube-ovn
COPY --from=builder /source/dist/images/kube-ovn-cmd /kube-ovn/kube-ovn-cmd
COPY --from=builder /source/dist/images/kube-ovn-daemon /kube-ovn/kube-ovn-daemon
COPY --from=builder /source/dist/images/kube-ovn-pinger /kube-ovn/kube-ovn-pinger
RUN ln -s /kube-ovn/kube-ovn-cmd /kube-ovn/kube-ovn-controller && \
    ln -s /kube-ovn/kube-ovn-cmd /kube-ovn/kube-ovn-monitor && \
    ln -s /kube-ovn/kube-ovn-cmd /kube-ovn/kube-ovn-speaker && \
    ln -s /kube-ovn/kube-ovn-cmd /kube-ovn/kube-ovn-webhook && \
    ln -s /kube-ovn/kube-ovn-cmd /kube-ovn/kube-ovn-controller-healthcheck && \
    ln -s /kube-ovn/kube-ovn-cmd /kube-ovn/kube-ovn-leader-checker && \
    ln -s /kube-ovn/kube-ovn-cmd /kube-ovn/kube-ovn-ic-controller && \
    setcap CAP_NET_BIND_SERVICE+eip /kube-ovn/kube-ovn-cmd && \
    setcap CAP_NET_RAW,CAP_NET_BIND_SERVICE+eip /kube-ovn/kube-ovn-pinger && \
    setcap CAP_NET_ADMIN,CAP_NET_RAW,CAP_NET_BIND_SERVICE,CAP_SYS_ADMIN+eip /kube-ovn/kube-ovn-daemon

FROM kubeovn/kube-ovn-base:$BASE_TAG

COPY --from=builder /source/dist/images/logrotate/* /etc/logrotate.d/
COPY --from=builder /source/dist/images/grace_stop_ovn_controller /usr/share/ovn/scripts/grace_stop_ovn_controller

COPY --from=setcap /kube-ovn /kube-ovn
COPY --from=builder /source/dist/images/kube-ovn /kube-ovn/kube-ovn
RUN /kube-ovn/iptables-wrapper-installer.sh --no-sanity-check

WORKDIR /kube-ovn
