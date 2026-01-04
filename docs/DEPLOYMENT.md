# Deployment Steps - Detailed Guide

## Prerequisites Checklist

Before starting, verify:

- [ ] VPS is accessible via SSH
- [ ] Ubuntu 22.04+ or Debian 12+ installed
- [ ] Root or sudo access available
- [ ] 4GB+ RAM (6-8GB recommended)
- [ ] 20GB+ free disk space
- [ ] Ports 80 and 443 available
- [ ] Domain DNS configured (if using domains)

---

## Step 0: Preflight Check

**Purpose:** Verify the VPS is ready for deployment

```bash
# Upload deployment package to /opt/netsurf-stack
cd /opt/netsurf-stack

# Make scripts executable
chmod +x scripts/*.sh

# Run preflight check
./scripts/00-preflight-check.sh
```

**What it checks:**
- Docker and Docker Compose installed
- Required ports available (80, 443, 5678, 8055, 3000)
- Sufficient disk space
- Sufficient RAM
- DNS resolution (if domains configured)

**If Docker not installed:**
```bash
# Install Docker (Ubuntu)
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version
docker compose version
```

---

## Step 1: Generate Secrets

**Purpose:** Create strong, unique passwords for all services

```bash
./scripts/01-generate-secrets.sh
```

**What it generates:**
- `POSTGRES_PASSWORD` - Database master password
- `N8N_BASIC_AUTH_PASSWORD` - n8n admin password
- `N8N_ENCRYPTION_KEY` - Encrypts stored credentials
- `DIRECTUS_KEY` - Application key
- `DIRECTUS_SECRET` - JWT secret
- `DIRECTUS_ADMIN_PASSWORD` - Admin login
- `SECRET_KEY_BASE` - Chatwoot Rails secret

**Output:** `.env` file created from `.env.example` with generated values

**Verify:**
```bash
cat .env | grep -E "(PASSWORD|SECRET|KEY)" | head -10
# Should show long random strings, not 'changeme'
```

---

## Step 2: Deploy Stack

**Purpose:** Start all containers

```bash
./scripts/02-deploy-stack.sh
```

**What it does:**
1. Validates .env file exists and has required vars
2. Pulls latest images
3. Starts containers in correct order
4. Waits for health checks to pass

**Manual equivalent:**
```bash
docker compose pull
docker compose up -d
docker compose ps
```

**Expected output:**
```
NAME                   STATUS                   PORTS
netsurf-caddy          Up (healthy)             80->80/tcp, 443->443/tcp
netsurf-chatwoot       Up (healthy)             3000/tcp
netsurf-chatwoot-sidekiq Up                      
netsurf-directus       Up (healthy)             8055/tcp
netsurf-n8n            Up (healthy)             5678/tcp
netsurf-n8n-worker     Up                       
netsurf-postgres       Up (healthy)             5432/tcp
netsurf-redis          Up (healthy)             6379/tcp
```

**Troubleshooting:**
- Container restarting? Check logs: `docker compose logs <name>`
- Out of memory? Check: `free -h` and `docker stats`
- Port conflict? Check: `sudo lsof -i :5678`

---

## Step 3: Run Migrations

**Purpose:** Initialize databases with required schemas

```bash
./scripts/03-run-migrations.sh
```

**What it does:**

### Chatwoot Migrations (critical!)
```bash
docker compose exec chatwoot-rails bundle exec rails db:chatwoot_prepare
```
This creates all Chatwoot tables. Without this, Chatwoot won't work!

### Directus Bootstrap
Directus auto-migrates on first start if `DIRECTUS_ADMIN_EMAIL` is set.

**Verify Chatwoot:**
```bash
docker compose exec postgres psql -U netsurf -d chatwoot -c "\dt" | head -20
# Should show tables like: accounts, users, conversations, messages, etc.
```

**Verify Directus:**
```bash
docker compose exec postgres psql -U netsurf -d directus -c "\dt" | head -10
# Should show tables like: directus_users, directus_collections, etc.
```

---

## Step 4: Health Check

**Purpose:** Verify all services are responding

```bash
./scripts/04-health-check.sh
```

**What it checks:**

### HTTP Endpoints
```bash
# n8n
curl -s -o /dev/null -w "%{http_code}" http://localhost:5678/healthz
# Expected: 200

# Directus
curl -s -o /dev/null -w "%{http_code}" http://localhost:8055/server/health
# Expected: 200

# Chatwoot
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api
# Expected: 200 or 401 (auth required = working)
```

### Database Connectivity
```bash
docker compose exec postgres psql -U netsurf -c "\l"
# Should list: n8n, directus, chatwoot databases
```

### Redis Connectivity
```bash
docker compose exec redis redis-cli ping
# Expected: PONG
```

---

## Step 5: Import n8n Workflows

**Purpose:** Load the pre-built automation workflows

```bash
./scripts/05-import-workflows.sh
```

**What it does:**
1. Waits for n8n to be fully ready
2. Authenticates with n8n API
3. Imports workflow JSON files
4. Activates workflows

**Manual import via UI:**
1. Go to http://localhost:5678 (or your domain)
2. Login with credentials from .env
3. Go to Workflows → Import from File
4. Select `n8n-workflows/01-inbound-message-triage.json`
5. Repeat for `02-social-media-auto-poster.json`
6. Activate both workflows

**Verify:**
```bash
curl -u "$N8N_USER:$N8N_PASSWORD" http://localhost:5678/api/v1/workflows | jq '.data | length'
# Expected: 2
```

---

## Step 6: Configure Directus Collections

**Purpose:** Create the data schema for Netsurf content

**Option A: Via Directus Admin UI**
1. Go to http://localhost:8055
2. Login with DIRECTUS_ADMIN_EMAIL / DIRECTUS_ADMIN_PASSWORD
3. Follow `directus/schema-setup.md` to create collections

**Option B: Via API (Claude Code can do this)**
```bash
# Get auth token
TOKEN=$(curl -s -X POST http://localhost:8055/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@netsurf.gy","password":"YOUR_PASSWORD"}' \
  | jq -r '.data.access_token')

# Create collection
curl -X POST http://localhost:8055/collections \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"collection":"internet_plans","meta":{"icon":"wifi"},"schema":{}}'
```

**Collections to create:**
1. `internet_plans` - Service offerings
2. `promotions` - Current deals
3. `faq` - Knowledge base
4. `business_info` - Contact info, hours
5. `conversation_logs` - AI interaction logs
6. `social_post_logs` - Social media post tracking

---

## Step 7: Configure Chatwoot Webhook

**Purpose:** Connect Chatwoot to n8n for AI processing

1. Login to Chatwoot at http://localhost:3000
2. Create admin account (first visit)
3. Go to Settings → Integrations → Webhooks
4. Add webhook:
   - URL: `http://n8n:5678/webhook/chatwoot-webhook`
   - Events: `message_created`

**Note:** Use `n8n` not `localhost` because they're on the same Docker network.

---

## Step 8: Add Credentials to n8n

**Purpose:** Configure API keys for external services

In n8n UI (http://localhost:5678):

1. **Anthropic (Claude)**
   - Credentials → New → Anthropic
   - Add API key from https://console.anthropic.com

2. **Directus**
   - Credentials → New → Header Auth
   - Name: `Directus API Token`
   - Header Name: `Authorization`
   - Header Value: `Bearer YOUR_STATIC_TOKEN`

3. **Chatwoot**
   - Credentials → New → Header Auth  
   - Name: `Chatwoot API Token`
   - Header Name: `api_access_token`
   - Header Value: Get from Chatwoot → Profile → Access Token

4. **Update workflow nodes** to use these credentials

---

## Step 9: Seed Sample Data

**Purpose:** Add initial content to Directus

```bash
# Run seed script (or import via API)
docker compose exec postgres psql -U netsurf -d directus < directus/seed-data.sql
```

**Or via Directus UI:**
1. Go to Content → Internet Plans
2. Add sample plans (Basic, Standard, Premium)
3. Go to Promotions → Add current offer
4. Go to FAQ → Add common questions

---

## Step 10: Test End-to-End

**Purpose:** Verify the complete flow works

### Test 1: n8n Webhook
```bash
curl -X POST http://localhost:5678/webhook/chatwoot-webhook \
  -H "Content-Type: application/json" \
  -d '{
    "message_type": "incoming",
    "content": "What internet plans do you have?",
    "conversation": {"id": 1, "contact_inbox": {"contact_id": 1}},
    "inbox": {"channel_type": "whatsapp"},
    "sender": {"name": "Test Customer"}
  }'
```

### Test 2: Directus API
```bash
curl http://localhost:8055/items/internet_plans \
  -H "Authorization: Bearer $DIRECTUS_TOKEN"
# Should return plans data
```

### Test 3: Chatwoot API
```bash
curl http://localhost:3000/api/v1/accounts/1/conversations \
  -H "api_access_token: $CHATWOOT_TOKEN"
# Should return conversations (empty initially)
```

---

## Step 11: Production Hardening

### Enable Firewall
```bash
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable

# Block direct access to app ports (use Caddy only)
sudo ufw deny 5678
sudo ufw deny 8055
sudo ufw deny 3000
```

### Set Up Backups
```bash
# Add to crontab
crontab -e

# Add line:
0 2 * * * /opt/netsurf-stack/scripts/backup.sh
```

### Set Up Monitoring
- Option 1: Install Netdata agent
- Option 2: Add to existing Zabbix
- Option 3: Use Uptime Kuma for basic checks

---

## Post-Deployment Checklist

- [ ] All containers healthy
- [ ] Can login to n8n, Directus, Chatwoot
- [ ] Both n8n workflows imported and active
- [ ] Directus has all 6 collections
- [ ] Chatwoot webhook configured
- [ ] Anthropic API key added to n8n
- [ ] Test message processed successfully
- [ ] Firewall configured
- [ ] Backup cron running
- [ ] Monitoring set up
- [ ] Staff trained on Directus
- [ ] Documentation handed off to Netsurf
