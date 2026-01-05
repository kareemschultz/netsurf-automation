# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Project Context

**Netsurf Automation** is a customer communications platform for Netsurf Group in Guyana:
- **Netsurf Power**: Solar panels, batteries, inverters, Starlink kits
- **Netsurf Nature Park**: Eco-tourism, cabins, camping

### Tech Stack
- **n8n**: Workflow automation (port 5678)
- **Directus**: Headless CMS (port 8055)
- **Chatwoot**: Customer support (port 3000)
- **PostgreSQL**: Database with pgvector
- **Redis**: Cache/queue
- **Pangolin**: Tunnel/reverse proxy

### Domains
- `n8n.ntpowergy.com` - Workflow automation
- `cms.ntpowergy.com` - Content management
- `chat.ntpowergy.com` - Customer support

---

## Quick Reference

```bash
# Beads issue tracking
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git

# Docker services
docker compose -f config/docker/docker-compose.yml ps
docker compose -f config/docker/docker-compose.yml logs <service>
docker compose -f config/docker/docker-compose.yml restart <service>

# n8n API
curl -H "X-N8N-API-KEY: $N8N_API_KEY" http://localhost:5678/api/v1/workflows
```

---

## Key Files

| File | Purpose |
|------|---------|
| `config/docker/docker-compose.yml` | Main services stack |
| `config/docker/.env` | Environment variables and secrets |
| `config/n8n/workflows/*.json` | n8n workflow templates |
| `config/pangolin/docker-compose.yml` | Tunnel client |
| `.mcp.json` | MCP server configuration |
| `docs/N8N-SETUP.md` | n8n configuration guide |

---

## Database Tables

Connect to PostgreSQL (`netsurf` database):

| Table | Purpose |
|-------|---------|
| `leads` | Customer inquiries from WhatsApp/web |
| `bookings` | Nature Park reservations |
| `products` | Solar/Starlink product catalog |
| `business_info` | Contact details and hours |
| `ticket_analytics` | Chatwoot metrics |
| `daily_reports` | Archived daily reports |

---

## n8n Workflows

| Workflow | Status | Purpose |
|----------|--------|---------|
| WhatsApp Lead Capture | Inactive | Auto-categorize incoming leads |
| Booking Confirmation | Inactive | Process Nature Park bookings |
| Chatwoot Ticket Handler | Inactive | Auto-respond & escalate |
| MCP Tools Server | Inactive | AI agent business tools |
| Daily Business Report | Inactive | 6 PM daily metrics |

**To activate**: Open n8n UI → Workflows → Toggle Active

---

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
