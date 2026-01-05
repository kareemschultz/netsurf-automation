# n8n Workflow Automation Setup Guide

This guide covers setting up n8n workflows and MCP integration for Netsurf automation.

## Access n8n

- **URL**: http://localhost:5678 (or your server IP)
- **Credentials**: Check `config/docker/.env` for `N8N_BASIC_AUTH_USER` and `N8N_BASIC_AUTH_PASSWORD`

## Step 1: Create API Key

1. Open n8n at http://localhost:5678
2. Go to **Settings** (gear icon) → **API**
3. Click **Create API Key**
4. Copy the key and save it to your `.env`:
   ```bash
   echo "N8N_API_KEY=your-key-here" >> config/docker/.env
   ```

## Step 2: Create PostgreSQL Credential

1. Go to **Credentials** → **Add Credential**
2. Search for **Postgres**
3. Configure:
   - **Name**: `Netsurf PostgreSQL`
   - **Host**: `postgres` (Docker network name)
   - **Database**: `netsurf`
   - **User**: `netsurf`
   - **Password**: (from `POSTGRES_PASSWORD` in .env)
   - **Port**: `5432`
4. Click **Save**

## Step 3: Import Workflows

### Option A: Manual Import
1. Go to **Workflows** → **Add Workflow** → **Import from File**
2. Import each file from `config/n8n/workflows/`:
   - `01-whatsapp-lead-capture.json` - Captures WhatsApp leads
   - `02-booking-confirmation.json` - Nature Park bookings
   - `03-chatwoot-ticket-handler.json` - Auto-respond & escalate
   - `04-mcp-server-tools.json` - MCP tools for AI agents
   - `05-daily-business-report.json` - Daily metrics report

### Option B: Using n8n API
```bash
# Set your API key
export N8N_API_KEY="your-api-key"

# Import each workflow
for file in config/n8n/workflows/*.json; do
  curl -X POST http://localhost:5678/api/v1/workflows \
    -H "X-N8N-API-KEY: $N8N_API_KEY" \
    -H "Content-Type: application/json" \
    -d @"$file"
done
```

## Step 4: Configure Workflow Credentials

After importing, update each workflow's credentials:

1. Open each workflow
2. Click on database nodes (PostgreSQL)
3. Select the `Netsurf PostgreSQL` credential
4. Save the workflow

## Step 5: Activate Workflows

1. Open each workflow
2. Toggle **Active** switch (top right)
3. Workflows are now live!

---

## MCP Integration

### Two Types of MCP

| Type | Purpose | How to Use |
|------|---------|------------|
| **n8n-mcp** (community) | AI builds n8n workflows | Claude Code can create/edit workflows |
| **Native MCP Trigger** | Expose workflows as AI tools | AI agents call your business functions |

### Using n8n-mcp (AI Workflow Builder)

This lets Claude Code help you build and manage n8n workflows.

**Setup (already in `.mcp.json`):**
```json
{
  "n8n-mcp": {
    "command": "npx",
    "args": ["n8n-mcp"],
    "env": {
      "MCP_MODE": "stdio",
      "N8N_API_URL": "http://localhost:5678",
      "N8N_API_KEY": "${N8N_API_KEY}"
    }
  }
}
```

**Alternative - Hosted Service (no setup):**
- Visit https://dashboard.n8n-mcp.com
- 100 free calls/day
- Connect via OAuth

### Using Native MCP Server Trigger

The `04-mcp-server-tools.json` workflow exposes business tools:

1. Import and activate the workflow
2. The MCP endpoint will be: `http://localhost:5678/webhook/netsurf-mcp/sse`
3. AI agents can discover and call these tools:
   - `get_solar_pricing` - Solar product pricing
   - `get_starlink_info` - Starlink kit information
   - `check_park_availability` - Cabin/camping availability
   - `create_booking` - Create park bookings
   - `send_whatsapp_message` - Send WhatsApp messages
   - `get_business_hours` - Contact info & hours

---

## Workflow Webhooks

After activating workflows, these endpoints are available:

| Webhook | URL | Purpose |
|---------|-----|---------|
| WhatsApp | `/webhook/whatsapp-webhook` | Receive WhatsApp messages |
| Bookings | `/webhook/booking-webhook` | Accept booking requests |
| Chatwoot | `/webhook/chatwoot-webhook` | Handle support tickets |
| MCP Tools | `/webhook/netsurf-mcp/sse` | AI tool discovery |

**Full URLs**: `http://your-server:5678/webhook/<path>`

---

## Database Tables

The automation workflows use these tables (in `netsurf` database):

| Table | Purpose |
|-------|---------|
| `leads` | WhatsApp/web lead captures |
| `bookings` | Nature Park reservations |
| `ticket_analytics` | Chatwoot ticket metrics |
| `daily_reports` | Archived daily reports |
| `products` | Solar/Starlink products |
| `business_info` | Business contact details |

---

## Troubleshooting

### Workflow not triggering?
- Check if workflow is **Active** (toggle is ON)
- Verify webhook URL is correct
- Check n8n logs: `docker compose logs n8n`

### Database connection failed?
- Verify credential settings
- Ensure host is `postgres` (not `localhost`)
- Check PostgreSQL is healthy: `docker compose ps`

### MCP not connecting?
- Ensure N8N_API_KEY is set
- Restart Claude Code after config changes
- Check n8n is running and accessible

---

## Resources

- [n8n Documentation](https://docs.n8n.io/)
- [n8n API Reference](https://docs.n8n.io/api/)
- [MCP Server Trigger](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-langchain.mcptrigger/)
- [n8n-mcp GitHub](https://github.com/czlonkowski/n8n-mcp)
- [n8n-mcp.com](https://www.n8n-mcp.com/) - Hosted MCP service
