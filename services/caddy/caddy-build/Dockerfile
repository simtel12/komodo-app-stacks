ARG CADDY_VERSION=2.11.2
ARG CA_FINGERPRINT="8b3190db484b16579775449cc46f7cf19abc7c5569a6c0c47972f5e3c1873f92"
ARG CERT_SERVER=https://10.0.0.30:9001

FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

RUN xcaddy build \
    --with github.com/caddy-dns/rfc2136 \
    --with github.com/lucaslorentz/caddy-docker-proxy/v2

FROM caddy:${CADDY_VERSION} AS caddy
ARG CA_FINGERPRINT
ARG CERT_SERVER

WORKDIR /

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

COPY trustca.crt /usr/local/share/ca-certificates/tinyca.lan.crt
RUN cat /usr/local/share/ca-certificates/tinyca.lan.crt >> /etc/ssl/certs/ca-certificates.crt
