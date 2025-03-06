ARG VERSION=v1.16.7
FROM quay.io/cilium/cilium-builder:714cfc3420a53a154dba0df63a43bc1378bebffd@sha256:13345d46c1a5b24e3b64c46ff4b334c5bbbbf784b769f1adbb8fad094f177f03 as builder
RUN curl -L https://github.com/cilium/cilium/archive/refs/tags/v1.16.7.tar.gz | tar --strip-components=1 -xzvf -

COPY patches /patches
RUN git apply /patches/*.diff

RUN make -C bpf
#RUN make -C daemon

FROM quay.io/cilium/cilium:${VERSION}
#COPY --from=builder /go/src/github.com/cilium/cilium/daemon/cilium-agent /usr/bin/cilium-agent
COPY --from=builder /go/src/github.com/cilium/cilium/bpf /var/lib/cilium/bpf
