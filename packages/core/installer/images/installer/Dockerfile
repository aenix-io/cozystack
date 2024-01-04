FROM alpine:3.19 AS builder

RUN apk add --no-cache make git
RUN apk add helm --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

COPY . /src/
WORKDIR /src

# Check that versions_map is not changed
RUN make -C packages/apps check-version-map

RUN make -C packages/system repo \
 && make -C packages/apps repo

FROM alpine:3.19

RUN apk add --no-cache make darkhttpd
RUN apk add helm kubectl --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

COPY packages/core/installer/images/installer/scripts/* /cozystack/
COPY --from=builder /src/packages/core /cozystack/packages/core
COPY --from=builder /src/packages/system /cozystack/packages/system
COPY --from=builder /src/packages/_out /cozystack/repos

WORKDIR /cozystack
ENTRYPOINT [ "/cozystack/run.sh" ]
