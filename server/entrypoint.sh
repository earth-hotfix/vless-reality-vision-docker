#!/bin/sh
set -e

# Validate required variables before substitution
: "${UUID:?UUID is required}"
: "${XRAY_PORT:?XRAY_PORT is required}"
: "${SNI_DOMAIN:?SNI_DOMAIN is required}"
: "${REALITY_PRIVATE_KEY:?REALITY_PRIVATE_KEY is required}"
: "${REALITY_SHORT_ID:?REALITY_SHORT_ID is required}"

envsubst < /etc/xray/config.json.tmpl > /etc/xray/config.json
exec xray run -config /etc/xray/config.json
