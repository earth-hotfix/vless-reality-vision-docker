#!/bin/bash
# One-command setup for VLESS + Reality + Vision
# Run from the repository root: bash scripts/setup.sh

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER_DIR="$REPO_ROOT/server"
CLIENT_DIR="$REPO_ROOT/client"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
die()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# --- prerequisites ---
command -v docker &>/dev/null || die "Docker is not installed"
docker info &>/dev/null       || die "Docker daemon is not running"

# --- generate UUID ---
info "Generating UUID..."
if command -v uuidgen &>/dev/null; then
    UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
elif [ -f /proc/sys/kernel/random/uuid ]; then
    UUID=$(cat /proc/sys/kernel/random/uuid)
elif command -v python3 &>/dev/null; then
    UUID=$(python3 -c "import uuid; print(uuid.uuid4())")
else
    die "Cannot generate UUID — install uuidgen or python3"
fi
info "UUID: $UUID"

# --- generate Reality keypair ---
info "Generating Reality x25519 keypair..."
KEYPAIR=$(docker run --rm ghcr.io/xtls/xray-core:latest xray x25519 2>/dev/null)
PRIVATE_KEY=$(echo "$KEYPAIR" | grep "Private key:" | awk '{print $3}')
PUBLIC_KEY=$(echo "$KEYPAIR"  | grep "Public key:"  | awk '{print $3}')
[ -n "$PRIVATE_KEY" ] || die "Failed to extract private key"
[ -n "$PUBLIC_KEY"  ] || die "Failed to extract public key"
info "Public key: $PUBLIC_KEY"

# --- generate short ID ---
SHORT_ID=$(openssl rand -hex 4)
info "Short ID: $SHORT_ID"

# --- prompt for server settings ---
read -rp "$(echo -e "${YELLOW}Server public IP or domain:${NC} ")" SERVER_IP
[ -n "$SERVER_IP" ] || die "SERVER_IP cannot be empty"

read -rp "$(echo -e "${YELLOW}Listening port [443]:${NC} ")" XRAY_PORT
XRAY_PORT="${XRAY_PORT:-443}"

read -rp "$(echo -e "${YELLOW}SNI domain [www.microsoft.com]:${NC} ")" SNI_DOMAIN
SNI_DOMAIN="${SNI_DOMAIN:-www.microsoft.com}"

read -rp "$(echo -e "${YELLOW}SOCKS5 local port [1080]:${NC} ")" SOCKS_PORT
SOCKS_PORT="${SOCKS_PORT:-1080}"

# --- write server .env ---
info "Writing server/.env..."
cat > "$SERVER_DIR/.env" <<EOF
XRAY_PORT=$XRAY_PORT
UUID=$UUID
SNI_DOMAIN=$SNI_DOMAIN
REALITY_PRIVATE_KEY=$PRIVATE_KEY
REALITY_SHORT_ID=$SHORT_ID
EOF

# --- write client .env ---
info "Writing client/.env..."
cat > "$CLIENT_DIR/.env" <<EOF
SERVER_IP=$SERVER_IP
SERVER_PORT=$XRAY_PORT
UUID=$UUID
SNI_DOMAIN=$SNI_DOMAIN
REALITY_PUBLIC_KEY=$PUBLIC_KEY
REALITY_SHORT_ID=$SHORT_ID
SOCKS_PORT=$SOCKS_PORT
EOF

# --- start server ---
info "Building and starting server..."
docker compose -f "$SERVER_DIR/docker-compose.yml" up -d --build

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "  Server : $SERVER_IP:$XRAY_PORT (VLESS+Reality+Vision)"
echo "  UUID   : $UUID"
echo "  Pub key: $PUBLIC_KEY"
echo "  ShortID: $SHORT_ID"
echo ""
echo "To start the client (run on your local machine):"
echo "  docker compose -f client/docker-compose.yml up -d --build"
echo ""
echo "SOCKS5 proxy will be available at 127.0.0.1:$SOCKS_PORT"
