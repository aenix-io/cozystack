FROM golang:alpine3.19 as builder

WORKDIR /workspace

COPY go.mod go.sum ./
RUN go mod download

COPY api api/
COPY pkg pkg/
COPY cmd cmd/

RUN CGO_ENABLED=0 go build -ldflags="-extldflags=-static" -o /cozystack-api cmd/cozystack-api/main.go

FROM scratch

COPY --from=builder /cozystack-api /cozystack-api

ENTRYPOINT ["/cozystack-api"]
