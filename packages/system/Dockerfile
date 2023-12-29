FROM alpine:3.19


ARG HELMWAVE_VERSION=0.33.0
RUN wget -c https://github.com/helmwave/helmwave/releases/download/v$HELMWAVE_VERSION/helmwave_${HELMWAVE_VERSION}_linux_amd64.tar.gz -O - | tar -xz \
 && mv helmwave /usr/local/bin/

ARG KUBECTL_VERSION=1.29.0
RUN wget https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl \
 && chmod +x kubectl \
 && mv kubectl /usr/local/bin/


COPY . /cozystack-system
WORKDIR /cozystack-system

CMD [ "reconcile.sh" ]
