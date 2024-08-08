# syntax=docker/dockerfile:experimental

ARG VERSION=v1.15.5

FROM golang:1.22-bookworm as builder

WORKDIR /source

COPY enforce-device-detection.diff /enforce-device-detection.diff

RUN wget -O- https://github.com/cilium/cilium/archive/refs/tags/v1.15.5.tar.gz | tar xzf - --strip-components=1
RUN git apply /enforce-device-detection.diff
RUN make build-agent

FROM quay.io/cilium/cilium:${VERSION}
COPY --from=builder /source/daemon/cilium-agent /usr/bin/cilium-agent
