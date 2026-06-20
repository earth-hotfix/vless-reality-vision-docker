#!/bin/bash
# Generate an x25519 keypair for Reality
# Output: Private key / Public key

if command -v xray &>/dev/null; then
    xray x25519
elif command -v docker &>/dev/null; then
    docker run --rm ghcr.io/xtls/xray-core:latest xray x25519
else
    echo "Error: neither 'xray' nor 'docker' found in PATH" >&2
    exit 1
fi
