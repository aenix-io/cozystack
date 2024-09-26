# Source: https://raw.githubusercontent.com/kubernetes/autoscaler/refs/heads/master/cluster-autoscaler/Dockerfile.amd64
ARG builder_image=docker.io/library/golang:1.22.5
ARG BASEIMAGE=gcr.io/distroless/static:nonroot-amd64
FROM ${builder_image} AS builder
RUN git clone https://github.com/kubernetes/autoscaler /src/autoscaler \
 && cd /src/autoscaler/cluster-autoscaler \
 && git checkout cluster-autoscaler-1.31.0

WORKDIR /src/autoscaler/cluster-autoscaler
RUN make build

FROM $BASEIMAGE
LABEL maintainer="Marcin Wielgus <mwielgus@google.com>"

COPY --from=builder /src/autoscaler/cluster-autoscaler/cluster-autoscaler-amd64 /cluster-autoscaler
WORKDIR /
CMD ["/cluster-autoscaler"]
