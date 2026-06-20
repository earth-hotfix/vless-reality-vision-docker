# VLESS + Reality + Vision Docker Deployment

Production-ready Docker deployment for VLESS + Reality + Vision proxy (Xray-core).

## Directory Layout

```
├── server/          # Xray server (VPS side)
├── client/          # Xray client (local side, SOCKS5 output)
├── scripts/         # Helper scripts
├── CONFIGURATION.md # All configurable parameters
└── TROUBLESHOOTING.md
```

## Quick Start (one command)

> Run on your **VPS**:

```bash
bash scripts/setup.sh
```

The script will:
1. Generate a UUID, Reality keypair, and short ID
2. Prompt for server IP, port, and SNI domain
3. Write `server/.env` and `client/.env`
4. Build and start the server container

Then copy `client/` to your local machine and:

```bash
cp client/.env.example client/.env   # already written by setup.sh if run on VPS
docker compose -f client/docker-compose.yml up -d --build
```

Your SOCKS5 proxy is now available at `127.0.0.1:1080`.

## Manual Setup

### 1. Generate credentials

```bash
# UUID
bash scripts/gen-uuid.sh

# Reality keypair (requires Docker)
bash scripts/gen-cert.sh

# Short ID
openssl rand -hex 4
```

### 2. Configure server

```bash
cd server
cp .env.example .env
# Fill in UUID, REALITY_PRIVATE_KEY, REALITY_SHORT_ID in .env
docker compose up -d --build
```

### 3. Configure client

```bash
cd client
cp .env.example .env
# Fill in SERVER_IP, UUID, REALITY_PUBLIC_KEY, REALITY_SHORT_ID in .env
docker compose up -d --build
```

### 4. Test

```bash
curl -x socks5h://127.0.0.1:1080 https://ifconfig.me
```

## Configuration

See [CONFIGURATION.md](CONFIGURATION.md) for all parameters.

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md).
