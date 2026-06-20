#!/bin/sh
set -e

# Validate required variables before substitution
: "${SERVER_IP:?SERVER_IP is required}"
: "${SERVER_PORT:?SERVER_PORT is required}"
: "${UUID:?UUID is required}"
: "${SNI_DOMAIN:?SNI_DOMAIN is required}"
: "${REALITY_PUBLIC_KEY:?REALITY_PUBLIC_KEY is required}"
: "${REALITY_SHORT_ID:?REALITY_SHORT_ID is required}"
: "${SOCKS_PORT:?SOCKS_PORT is required}"

envsubst < /etc/xray/config.json.tmpl > /etc/xray/config.json
exec xray run -config /etc/xray/config.json
