# Claude Code Instructions

## 🎯 Your Mission

Deploy a complete customer communications automation stack for Netsurf WISP. This includes:
1. n8n (workflow automation)
2. Chatwoot (customer inbox)
3. Directus (content management)
4. Supporting infrastructure (PostgreSQL, Redis, Caddy)

---

## 🧠 Context You Need

### About Netsurf
- Internet Service Provider (WISP) in Guyana
- Needs AI-powered customer support on WhatsApp, Facebook, Instagram
- Needs automated social media posting for promotions
- Non-technical staff must be able to update content without developer help

### About the Architecture
```
Customer Message (WhatsApp/FB/IG/Web)
    ↓
Chatwoot (receives, routes)
    ↓ webhook
n8n (orchestration)
    ↓ fetch context
Directus (plans, promos, FAQ data)
    ↓ send to AI
Claude API (generate response)
    ↓
n8n (post back)
    ↓
Chatwoot (send to customer)
```

### WhatsApp Policy Constraint (CRITICAL)
As of Jan 15, 2026, WhatsApp bans "general-purpose AI chatbots". The bot MUST:
- Only handle Netsurf business queries
- Always offer human escalation ("Type AGENT for help")
- Never pretend to be human
- Have strict scope guardrails

---

## 🔧 Tools Available to You

### Shell Access
Full bash access to the VPS. Use for:
- Docker commands
- File operations
- Service management
- Database operations

### MCP Servers (if configured)

**n8n MCP** (`@n8n/n8n-mcp-server`)
- Create/update/delete workflows
- Manage credentials
- Trigger workflow executions
- Check execution history

**PostgreSQL MCP** (`@modelcontextprotocol/server-postgres`)
- Direct SQL queries
- Schema inspection
- Data operations

**Filesystem MCP** (`@modelcontextprotocol/server-filesystem`)
- Read/write config files
- Check logs
- Manage deployment files

### APIs You'll Call

**n8n REST API** (port 5678)
```bash
# List workflows
curl -u admin:password http://localhost:5678/api/v1/workflows

# Import workflow
curl -X POST -u admin:password \
  -H "Content-Type: application/json" \
  -d @workflow.json \
  http://localhost:5678/api/v1/workflows
```

**Directus REST API** (port 8055)
```bash
# Get auth token
curl -X POST http://localhost:8055/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@netsurf.gy","password":"xxx"}'

# Create collection
curl -X POST http://localhost:8055/collections \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"collection":"internet_plans","schema":{}}'
```

**Chatwoot REST API** (port 3000)
```bash
# After getting API key from admin panel
curl -H "api_access_token: TOKEN" \
  http://localhost:3000/api/v1/accounts/1/inboxes
```

---

## 📋 Deployment Sequence

Execute these in order. Do not skip steps.

### Phase 1: Preflight (5 min)
```bash
./scripts/00-preflight-check.sh
```
Verifies: Docker, disk space, ports, DNS (if using domains)

### Phase 2: Secrets (2 min)
```bash
./scripts/01-generate-secrets.sh
```
Generates: All passwords, keys, saves to .env

### Phase 3: Deploy Stack (10 min)
```bash
./scripts/02-deploy-stack.sh
```
Does: docker compose up, waits for healthy

### Phase 4: Migrations (5 min)
```bash
./scripts/03-run-migrations.sh
```
Does: Chatwoot db:prepare, Directus bootstrap

### Phase 5: Health Check (2 min)
```bash
./scripts/04-health-check.sh
```
Verifies: All services responding, DBs exist

### Phase 6: Import Workflows (5 min)
```bash
./scripts/05-import-workflows.sh
```
Does: Imports n8n workflows via API

### Phase 7: Configure Integrations (manual/guided)
- Create Directus collections
- Seed sample data
- Configure Chatwoot webhook
- Add API credentials to n8n

---

## 🛠️ Common Commands You'll Need

### Docker
```bash
# Stack status
docker compose ps

# View logs (follow)
docker compose logs -f n8n
docker compose logs -f chatwoot-rails
docker compose logs -f directus

# Restart a service
docker compose restart n8n

# Full restart
docker compose down && docker compose up -d

# Enter container shell
docker compose exec n8n sh
docker compose exec postgres psql -U netsurf

# Check resources
docker stats
```

### Database
```bash
# Connect to PostgreSQL
docker compose exec postgres psql -U netsurf -d directus

# List databases
\l

# List tables in current DB
\dt

# Backup all
docker compose exec postgres pg_dumpall -U netsurf > backup.sql
```

### File Operations
```bash
# Edit .env
nano /opt/netsurf-stack/.env

# View Caddy logs for SSL issues
docker compose logs caddy

# Check generated secrets
cat .env | grep PASSWORD
```

---

## 🚨 Error Handling

### Container Won't Start
```bash
# Check logs
docker compose logs <service> --tail 100

# Common fixes:
# - Port conflict: change port in docker-compose.yml
# - Missing env var: check .env has all required vars
# - Volume permission: chown -R 1000:1000 ./data
```

### Chatwoot Migration Fails
```bash
# Must run in correct container
docker compose exec chatwoot-rails bundle exec rails db:chatwoot_prepare

# If "database doesn't exist"
docker compose exec postgres createdb -U netsurf chatwoot
```

### n8n Webhook Not Receiving
```bash
# Check WEBHOOK_URL is set correctly in .env
grep WEBHOOK_URL .env

# Should match external URL:
# WEBHOOK_URL=https://n8n.netsurf.gy/ (with trailing slash)
```

### Directus Won't Start
```bash
# Usually missing KEY or SECRET
grep DIRECTUS_KEY .env
grep DIRECTUS_SECRET .env

# Both must be set (use: openssl rand -hex 32)
```

---

## ✅ Verification Checklist

After each phase, verify before proceeding:

### After Phase 3 (Deploy)
- [ ] `docker compose ps` shows all containers "Up"
- [ ] No containers restarting in a loop
- [ ] `docker stats` shows reasonable memory usage

### After Phase 4 (Migrations)
- [ ] Chatwoot shows "Database migrated" or similar
- [ ] Directus container logs show "Server started"

### After Phase 5 (Health Check)
- [ ] n8n responds: `curl -I http://localhost:5678`
- [ ] Directus responds: `curl -I http://localhost:8055`
- [ ] Chatwoot responds: `curl -I http://localhost:3000`

### After Phase 6 (Workflows)
- [ ] n8n shows 2 workflows in UI
- [ ] Workflows are set to "Active"

---

## 📝 Notes for Kareem

After Claude Code completes deployment:

1. **Login to each service and change default passwords**
2. **Set up Chatwoot channels:**
   - WhatsApp Cloud API
   - Facebook Messenger
   - Website widget
3. **Create Chatwoot webhook pointing to n8n**
4. **Add Claude API key to n8n credentials**
5. **Populate Directus with real Netsurf data**
6. **Train staff on Directus content updates**

---

## 📊 Issue Tracking with Beads

This project uses **beads** (`bd`) for local-first issue tracking synced to git.

### Quick Reference
```bash
# View all issues
bd list

# View ready-to-work tasks (no blockers)
bd ready

# Show issue details
bd show <issue-id>

# Create new issue
bd create "Issue title" --priority P1 --labels "label1,label2"

# Update issue status
bd update <issue-id> --status in_progress
bd update <issue-id> --status open

# Close completed issue
bd close <issue-id> --reason "Completed successfully"

# Sync with GitHub (IMPORTANT - do this after changes)
bd sync
```

### Priority Levels
- **P0** - Critical/Blocking
- **P1** - High priority
- **P2** - Medium priority (default)
- **P3** - Low priority
- **P4** - Nice to have

### Issue Statuses
- `open` - Not started
- `in_progress` - Currently working on
- `closed` - Completed

### Workflow
1. Check `bd list` or `bd ready` for available tasks
2. Update issue to `in_progress` when starting work
3. Do the work
4. Close issue with `bd close <id> --reason "what was done"`
5. Run `bd sync` to push changes to GitHub

### How Sync Works
- Issues are stored in `.beads/issues.jsonl`
- `bd sync` commits and pushes to the git remote
- This keeps issue history in version control
- All team members can see issues by pulling the repo

### After Making Changes
Always commit code changes AND sync beads:
```bash
# Commit your code changes
git add -A && git commit -m "feat: description"
git push

# Sync beads issues
bd sync
```

---

## 🆘 If Stuck

1. Check service logs: `docker compose logs <service>`
2. Check OFFICIAL-DOCS.md for the relevant service
3. Fetch the official documentation URL
4. Search for the specific error message
5. If infrastructure issue, check VPS resources (RAM, disk)
