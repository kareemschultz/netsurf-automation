# Pangolin Reverse Proxy Configuration

Since you're using Pangolin as your reverse proxy instead of Caddy, here's how to configure routes for the Netsurf Communications stack.

## Required Routes

Configure these routes in your Pangolin dashboard/config:

### 1. n8n (Workflow Automation)

| Setting | Value |
|---------|-------|
| **Domain** | `n8n.netsurf.gy` |
| **Target** | `http://localhost:5678` or `http://netsurf-n8n:5678` |
| **SSL** | Enable (Let's Encrypt) |
| **WebSocket** | Enable (required for n8n UI) |
| **Headers** | Forward X-Real-IP, X-Forwarded-For |

**Important:** n8n requires WebSocket support for the UI to work properly.

### 2. Directus (CMS)

| Setting | Value |
|---------|-------|
| **Domain** | `cms.netsurf.gy` |
| **Target** | `http://localhost:8055` or `http://netsurf-directus:8055` |
| **SSL** | Enable |
| **Max Body Size** | 100MB (for file uploads) |

### 3. Chatwoot (Customer Support)

| Setting | Value |
|---------|-------|
| **Domain** | `chat.netsurf.gy` |
| **Target** | `http://localhost:3000` or `http://netsurf-chatwoot:3000` |
| **SSL** | Enable |
| **WebSocket** | Enable (required for real-time chat) |

**Important:** Chatwoot requires WebSocket for real-time message updates.

---

## Network Configuration Options

### Option A: Host Network (Simpler)

Services expose ports directly to localhost:
- n8n: `localhost:5678`
- Directus: `localhost:8055`
- Chatwoot: `localhost:3000`

Pangolin routes to these localhost ports.

### Option B: Docker Network (More Isolated)

If Pangolin runs in Docker on the same host, connect it to `netsurf-network`:

```yaml
# In Pangolin's docker-compose.yml
networks:
  netsurf-network:
    external: true
```

Then route to container names:
- n8n: `http://netsurf-n8n:5678`
- Directus: `http://netsurf-directus:8055`
- Chatwoot: `http://netsurf-chatwoot:3000`

---

## DNS Configuration

Create A records pointing to your VPS IP:

```
n8n.netsurf.gy      A    YOUR_VPS_IP
cms.netsurf.gy      A    YOUR_VPS_IP
chat.netsurf.gy     A    YOUR_VPS_IP
```

Or use CNAME if you have a main domain:

```
n8n.netsurf.gy      CNAME    netsurf.gy
cms.netsurf.gy      CNAME    netsurf.gy
chat.netsurf.gy     CNAME    netsurf.gy
```

---

## Webhook URL Configuration

After setting up Pangolin routes, update `.env`:

```bash
# n8n webhook must match the public URL exactly
N8N_WEBHOOK_URL=https://n8n.netsurf.gy/
N8N_HOST=n8n.netsurf.gy
N8N_PROTOCOL=https

# Directus public URL
DIRECTUS_PUBLIC_URL=https://cms.netsurf.gy

# Chatwoot frontend URL
CHATWOOT_FRONTEND_URL=https://chat.netsurf.gy
```

Then restart the stack:
```bash
cd /opt/netsurf-comms/docker
docker compose down
docker compose up -d
```

---

## Testing Routes

After configuration, verify each route:

```bash
# n8n
curl -I https://n8n.netsurf.gy/healthz
# Expected: HTTP 200

# Directus
curl -I https://cms.netsurf.gy/server/health
# Expected: HTTP 200

# Chatwoot
curl -I https://chat.netsurf.gy/api
# Expected: HTTP 200 or 401
```

---

## Firewall Rules

If using UFW, only Pangolin needs external access:

```bash
# Allow HTTP/HTTPS through Pangolin
sudo ufw allow 80
sudo ufw allow 443

# Block direct access to app ports (optional but recommended)
sudo ufw deny 5678
sudo ufw deny 8055
sudo ufw deny 3000
```

---

## Troubleshooting

### WebSocket Not Working

Symptoms: n8n or Chatwoot UI doesn't update in real-time

Check Pangolin config:
- Ensure WebSocket/Upgrade headers are forwarded
- Check `Connection: Upgrade` header is passed through

### 502 Bad Gateway

Symptoms: Pangolin can't reach backend

```bash
# Check container is running
docker compose ps

# Check container logs
docker compose logs n8n

# Test from host
curl http://localhost:5678/healthz
```

### SSL Certificate Issues

If Let's Encrypt fails:
1. Verify DNS is pointing to correct IP
2. Check ports 80/443 are open
3. Wait a few minutes and retry
4. Check Pangolin logs for ACME errors

---

## Internal Service Communication

For Chatwoot webhook to n8n, use internal Docker network:

```
Webhook URL: http://netsurf-n8n:5678/webhook/chatwoot-webhook
```

NOT the external URL (avoids going through Pangolin for internal calls).
