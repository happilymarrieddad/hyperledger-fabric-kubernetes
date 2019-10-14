FROM golang:1.12 AS builder
WORKDIR /app

COPY . .
RUN go build -o /app/api main.go

FROM alpine:edge
WORKDIR /app

RUN apk add --no-cache libc6-compat

COPY --from=builder /app/api /app/api
COPY ./static /app/static

CMD ["/app/api"]