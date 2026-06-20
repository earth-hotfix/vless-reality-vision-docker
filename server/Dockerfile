FROM ghcr.io/xtls/xray-core:latest AS xray

FROM alpine:3.19

RUN apk add --no-cache gettext ca-certificates tzdata tini

COPY --from=xray /usr/local/bin/xray /usr/local/bin/xray
COPY --from=xray /usr/local/share/xray /usr/local/share/xray

RUN mkdir -p /etc/xray /var/log/xray

COPY xray-config.json /etc/xray/config.json.tmpl
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/sbin/tini", "--", "/entrypoint.sh"]
