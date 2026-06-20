#!/bin/sh
set -e
envsubst < /etc/xray/config.json.tmpl > /etc/xray/config.json
exec xray run -config /etc/xray/config.json
