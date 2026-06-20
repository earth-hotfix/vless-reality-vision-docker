# Configuration Reference

## Server (`server/.env`)

| Variable | Default | Description |
|---|---|---|
| `XRAY_PORT` | `443` | Inbound listening port |
| `UUID` | — | VLESS client UUID (`gen-uuid.sh`) |
| `SNI_DOMAIN` | `www.microsoft.com` | Reality camouflage domain — must support TLS 1.3 and be reachable from your VPS |
| `REALITY_PRIVATE_KEY` | — | x25519 private key (`gen-cert.sh`) |
| `REALITY_SHORT_ID` | — | 8 hex chars (`openssl rand -hex 4`) |

## Client (`client/.env`)

| Variable | Default | Description |
|---|---|---|
| `SERVER_IP` | — | VPS public IP or hostname |
| `SERVER_PORT` | `443` | Must match server `XRAY_PORT` |
| `UUID` | — | Must match server `UUID` |
| `SNI_DOMAIN` | `www.microsoft.com` | Must match server `SNI_DOMAIN` |
| `REALITY_PUBLIC_KEY` | — | x25519 public key (pair of server private key) |
| `REALITY_SHORT_ID` | — | Must match server `REALITY_SHORT_ID` |
| `SOCKS_PORT` | `1080` | Local SOCKS5 proxy port (bound to `127.0.0.1`) |

## Reality SNI Domain Selection

The SNI domain must:
- Be a real, reachable HTTPS site (TLS 1.3 required)
- Be reachable from your VPS (not blocked)
- Have a response size similar to real traffic

Good choices: `www.microsoft.com`, `www.amazon.com`, `addons.mozilla.org`

## Logging

Server logs are stored in `server/logs/` (Docker volume mount).  
Adjust verbosity by changing `loglevel` in `xray-config.json`:  
`"none"` | `"error"` | `"warning"` | `"info"` | `"debug"`

## Port Exposure

- **Server**: port `XRAY_PORT` is mapped to `0.0.0.0` (accessible from the internet).
- **Client**: SOCKS5 port is bound to `127.0.0.1` only for security.  
  To expose it to the Docker network, edit `client/docker-compose.yml` and change  
  `127.0.0.1:${SOCKS_PORT}` → `${SOCKS_PORT}`.

## Updating Xray

The images use `ghcr.io/xtls/xray-core:latest`. To update:

```bash
docker compose down
docker compose build --pull
docker compose up -d
```
