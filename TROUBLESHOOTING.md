# Troubleshooting

## View logs

```bash
# Server
docker compose -f server/docker-compose.yml logs -f

# Client
docker compose -f client/docker-compose.yml logs -f

# Persistent log files (server only)
tail -f server/logs/error.log
```

---

## Connection refused on SOCKS5 port

**Symptom:** `curl: (7) Failed to connect to 127.0.0.1 port 1080`

1. Check the client container is running: `docker ps`
2. Check `client/.env` has `SOCKS_PORT=1080`
3. Check the container started cleanly: `docker compose -f client/docker-compose.yml logs`

---

## Xray exits immediately after start

The config template substitution failed.  
Check that **all** required variables are set in `.env`:

```bash
# Server
grep -E '^(XRAY_PORT|UUID|SNI_DOMAIN|REALITY_PRIVATE_KEY|REALITY_SHORT_ID)' server/.env

# Client
grep -E '^(SERVER_IP|SERVER_PORT|UUID|SNI_DOMAIN|REALITY_PUBLIC_KEY|REALITY_SHORT_ID|SOCKS_PORT)' client/.env
```

---

## Traffic not flowing / timeouts

1. **Firewall** — open `XRAY_PORT` TCP on the VPS:
   ```bash
   ufw allow 443/tcp   # or your custom port
   ```
2. **SNI domain reachable** — test from VPS:
   ```bash
   curl -I https://www.microsoft.com
   ```
3. **Keys mismatch** — confirm `REALITY_PUBLIC_KEY` (client) matches the public key  
   that corresponds to `REALITY_PRIVATE_KEY` (server):
   ```bash
   bash scripts/gen-cert.sh   # re-run and compare
   ```
4. **UUID mismatch** — server and client `UUID` must be identical.
5. **Short ID mismatch** — server and client `REALITY_SHORT_ID` must be identical.

---

## Reality TLS handshake fails

- Ensure the SNI domain supports **TLS 1.3** (most modern CDN sites do).
- Ensure the VPS can reach `${SNI_DOMAIN}:443` (not blocked by the VPS firewall or ISP).
- Try a different SNI domain: `www.amazon.com`, `addons.mozilla.org`.

---

## "invalid UUID" error in logs

Run `bash scripts/gen-uuid.sh` to get a properly formatted UUID and update both `.env` files.

---

## Rebuilding after config changes

```bash
docker compose -f server/docker-compose.yml up -d --build
docker compose -f client/docker-compose.yml up -d --build
```

---

## Check container health status

```bash
docker inspect --format '{{.State.Health.Status}}' xray-server
docker inspect --format '{{.State.Health.Status}}' xray-client
```
