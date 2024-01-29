FROM alpine:3.19 AS builder

RUN apk add --no-cache make git
RUN apk add helm --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

COPY . /src/
WORKDIR /src

# Check that versions_map is not changed
RUN make repos

FROM alpine:3.19

RUN apk add --no-cache make darkhttpd
RUN apk add helm kubectl --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

COPY scripts /cozystack/scripts
COPY --from=builder /src/packages/core /cozystack/packages/core
COPY --from=builder /src/packages/system /cozystack/packages/system
COPY --from=builder /src/_out/repos /cozystack/assets/repos
COPY dashboards /cozystack/assets/dashboards

WORKDIR /cozystack
ENTRYPOINT [ "/cozystack/scripts/installer.sh" ]
