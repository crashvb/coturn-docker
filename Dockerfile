FROM coturn/coturn:4.19.2-r0-debian@sha256:ccdbc51e6f072130b0fc9eebda21f8d026d0a25581746c52557e887818011a3f AS coturn

FROM crashvb/supervisord:202610210041@sha256:689d6c587164f57d8ea8888265850c3d6c65e020d345a82f772eacfed9ec0f82
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:689d6c587164f57d8ea8888265850c3d6c65e020d345a82f772eacfed9ec0f82" \
	org.opencontainers.image.base.name="crashvb/supervisord:202610210041" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing coturn." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/coturn-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/coturn" \
	org.opencontainers.image.url="https://github.com/crashvb/coturn-docker"

# Install packages, download files ...
RUN docker-apt libevent-core-2.1-7t64 libevent-extra-2.1-7t64 libevent-openssl-2.1-7t64 libevent-pthreads-2.1-7t64 libhiredis1.1.0 libmariadb3 libmicrohttpd12t64 libpq5 libsasl2-2 libsnappy1v5 libsqlite3-0 libssl3t64 libutf8proc3 libzstd1 ssl-cert zlib1g

# Configure: coturn
ENV COTURN_CONFIG=/etc/coturn COTURN_IP_LISTENING=0.0.0.0,:: COTURN_IP_RELAY=0.0.0.0,:: COTURN_PORT_RANGE=49152-49200
COPY --from=coturn /usr/bin/turnserver /usr/bin/
COPY --from=coturn /usr/share/licenses/coturn/ /usr/share/licenses/coturn/
COPY --from=coturn /var/lib/coturn/ /var/lib/coturn/
# Coturn requires the MongoDB 1.x ABI, absent from Ubuntu 26.04.
COPY --from=coturn /usr/lib/*/libbson-1.0.so.* /usr/lib/*/libmongoc-1.0.so.* /usr/lib/*/libmongocrypt.so.* /usr/local/lib/
COPY --from=coturn /usr/share/doc/libbson-1.0-0t64/copyright /usr/share/licenses/coturn/libbson
COPY --from=coturn /usr/share/doc/libmongoc-1.0-0t64/copyright /usr/share/licenses/coturn/libmongoc
COPY --from=coturn /usr/share/doc/libmongocrypt0/copyright /usr/share/licenses/coturn/libmongocrypt
COPY turnserver.conf.template /usr/local/share/coturn/
RUN ldconfig && \
	usermod --append --groups=ssl-cert nobody && \
	install --directory --mode=0755 ${COTURN_CONFIG} && \
	chown --recursive nobody:nogroup /var/lib/coturn

# Configure: supervisor
COPY supervisord.coturn.conf /etc/supervisor/conf.d/coturn.conf

# Configure: entrypoint
COPY entrypoint.coturn /etc/entrypoint.d/coturn

# Configure: healthcheck
COPY healthcheck.coturn /etc/healthcheck.d/coturn

EXPOSE 3478/tcp 3478/udp 5349/tcp 5349/udp

VOLUME ${COTURN_CONFIG}
