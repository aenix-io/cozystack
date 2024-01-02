FROM alpine:3.19

RUN apk add --no-cache make darkhttpd
RUN apk add helm kubectl --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community

COPY packages /cozystack/packages
RUN make -C /cozystack/packages/system repo

RUN ln -s /cozystack/packages/core/installer/images/installer/scripts /scripts

ENTRYPOINT [ "/scripts/run.sh" ]
