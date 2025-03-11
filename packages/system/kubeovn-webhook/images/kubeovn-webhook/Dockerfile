FROM golang:1.23 as builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o webhook .

FROM alpine:3.21.3
WORKDIR /app

COPY --from=builder /app/webhook /app/webhook

EXPOSE 8443
USER 65534
ENTRYPOINT ["/app/webhook", "--tls-cert-file=/etc/webhook/certs/tls.crt", "--tls-key-file=/etc/webhook/certs/tls.key"]
