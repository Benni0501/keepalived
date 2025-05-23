# Builder stage
FROM alpine:3.21.3 AS builder

ARG KEEPALIVED_VERSION=2.3.3
COPY tools/install.sh /install.sh
RUN chmod +x /install.sh
RUN /install.sh ${KEEPALIVED_VERSION}

# Final stage
FROM alpine:3.21.3

LABEL maintainer="Benjamin Kogler"
LABEL description="Keepalived container"

RUN apk --no-cache add \
  file \
  ipset \
  iptables \
  libip6tc \
  libip4tc \
  libmagic \
  libnl3 \
  libgcc \
  net-snmp \
  openssl \
  pcre2 \
  envsubst \
  curl \
  jq

RUN addgroup -S keepalived_script && adduser -D -S -G keepalived_script keepalived_script
COPY --from=builder /usr/sbin/keepalived /usr/sbin/keepalived
COPY assets/keepalived.conf /etc/keepalived/keepalived.conf
COPY assets/entrypoint.sh /entrypoint.sh

# workaround for https://github.com/acassen/keepalived/issues/2503
RUN mkdir -p /usr/share/iproute2/rt_addrprotos.d
RUN mkdir -p /etc/iproute2/rt_addrprotos.d

CMD ["/bin/sh", "/entrypoint.sh"]