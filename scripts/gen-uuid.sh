#!/bin/bash
# Generate a random UUID for VLESS

if command -v uuidgen &>/dev/null; then
    uuidgen | tr '[:upper:]' '[:lower:]'
elif [ -f /proc/sys/kernel/random/uuid ]; then
    cat /proc/sys/kernel/random/uuid
elif command -v python3 &>/dev/null; then
    python3 -c "import uuid; print(uuid.uuid4())"
else
    echo "Error: no UUID generator found (install uuidgen or python3)" >&2
    exit 1
fi
