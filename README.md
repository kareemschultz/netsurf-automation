# Netsurf Automation

<div align="center">

![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![n8n](https://img.shields.io/badge/n8n-EA4B71?style=for-the-badge&logo=n8n&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=for-the-badge&logo=redis&logoColor=white)

**AI-powered customer communications platform for the Netsurf Group of Companies**

[Getting Started](#quick-start) • [Documentation](#documentation) • [Services](#services) • [Architecture](#architecture)

</div>

---

## Overview

This platform unifies customer support, workflow automation, and content management across the Netsurf businesses in Guyana.

### Netsurf Power
> Solar energy solutions & Starlink satellite internet

| | |
|---|---|
| **Products** | Solar panels, lithium batteries, hybrid inverters, Starlink kits |
| **Contact** | +592-644-6840 / 611-9443 / 621-8271 |
| **Location** | 56 Chalmers Place, Georgetown |
| **Domain** | [ntpowergy.com](https://ntpowergy.com) |

### Netsurf Nature Park
> Eco-tourism retreat in Linden

| | |
|---|---|
| **Services** | Day trips, cabin stays, camping, birdwatching |
| **Reservations** | +592-611-9443 / 621-8271 |
| **Location** | Linden Highway, Guyana |

---

## Services

| Service | Purpose | URL | Health |
|---------|---------|-----|--------|
| **n8n** | Workflow automation | [n8n.ntpowergy.com](https://n8n.ntpowergy.com) | `/healthz` |
| **Directus** | Content management | [cms.ntpowergy.com](https://cms.ntpowergy.com) | `/server/health` |
| **Chatwoot** | Customer messaging | [chat.ntpowergy.com](https://chat.ntpowergy.com) | `/api` |
| PostgreSQL | Database (pgvector) | Internal :5432 | - |
| Redis | Cache/Queue | Internal :6379 | - |

---

## Quick Start

### Prerequisites

- Docker & Docker Compose v2+
- 4GB+ RAM (8GB recommended)
- 20GB+ free disk space

### Deployment

```bash
# Clone repository
git clone https://github.com/kareemschultz/netsurf-automation.git
cd netsurf-automation

# Start services
docker compose -f config/docker/docker-compose.yml up -d

# Run Chatwoot migrations
docker compose -f config/docker/docker-compose.yml run --rm chatwoot-rails \
  bundle exec rails db:chatwoot_prepare

# Start Pangolin tunnel (optional)
docker compose -f config/pangolin/docker-compose.yml up -d

# Check status
docker compose -f config/docker/docker-compose.yml ps
```

### Default Credentials

After deployment, check `config/docker/.env` for generated credentials:
- **n8n**: `N8N_BASIC_AUTH_USER` / `N8N_BASIC_AUTH_PASSWORD`
- **Directus**: `DIRECTUS_ADMIN_EMAIL` / `DIRECTUS_ADMIN_PASSWORD`
- **Chatwoot**: Created on first visit

---

## Architecture

```
                                 ┌─────────────────────────────────────┐
                                 │         Pangolin Tunnel             │
                                 │   (Reverse Proxy & SSL Termination) │
                                 └──────────────────┬──────────────────┘
                                                    │
        ┌───────────────────────────────────────────┼───────────────────────────────────────────┐
        │                                           │                                           │
        ▼                                           ▼                                           ▼
┌───────────────┐                         ┌─────────────────┐                         ┌─────────────────┐
│     n8n       │                         │    Directus     │                         │    Chatwoot     │
│   :5678       │◄───────────────────────►│     :8055       │                         │     :3000       │
│  Workflows    │        API/Webhooks     │   CMS/Content   │                         │  Omnichannel    │
└───────┬───────┘                         └────────┬────────┘                         └────────┬────────┘
        │                                          │                                           │
        │                                          │                                           │
        └──────────────────────────┬───────────────┴───────────────────────────────────────────┘
                                   │
                                   ▼
                          ┌────────────────┐        ┌────────────────┐
                          │   PostgreSQL   │◄──────►│     Redis      │
                          │   (pgvector)   │        │   Cache/Queue  │
                          │     :5432      │        │     :6379      │
                          └────────────────┘        └────────────────┘
```

---

## n8n Workflows

Pre-configured automation workflows:

| Workflow | Purpose | Trigger |
|----------|---------|---------|
| **WhatsApp Lead Capture** | Auto-categorize and save leads | Webhook |
| **Booking Confirmation** | Nature Park reservation processing | Webhook |
| **Chatwoot Ticket Handler** | Auto-respond & escalate tickets | Webhook |
| **MCP Tools Server** | Expose business tools for AI agents | MCP |
| **Daily Business Report** | Aggregate daily metrics | Schedule (6 PM) |

Import workflows from `config/n8n/workflows/` via n8n UI or API.

---

## Project Structure

```
netsurf-automation/
├── .beads/                 # AI agent issue tracking
├── .mcp.json               # MCP server configuration
├── config/
│   ├── docker/             # Docker Compose & environment
│   │   ├── docker-compose.yml
│   │   ├── .env
│   │   └── init-databases.sql
│   ├── n8n/
│   │   └── workflows/      # n8n workflow JSON files
│   └── pangolin/           # Tunnel client config
├── docs/
│   └── N8N-SETUP.md        # n8n configuration guide
└── README.md
```

---

## MCP Integration

Two MCP configurations available:

| MCP Server | Purpose |
|------------|---------|
| **n8n-mcp** | AI assistant for building n8n workflows (543 nodes, 2700+ templates) |
| **netsurf-mcp** | Business tools exposed via n8n native MCP Server Trigger |

See `.mcp.json` for configuration details.

---

## Documentation

| Document | Description |
|----------|-------------|
| [N8N-SETUP.md](docs/N8N-SETUP.md) | n8n workflow configuration and MCP integration |
| [ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture and multi-WhatsApp setup |
| [STAFF-TRAINING-GUIDE.md](docs/training/STAFF-TRAINING-GUIDE.md) | Staff training with diagrams |
| [CLAUDE-CODE.md](docs/CLAUDE-CODE.md) | Claude Code deployment instructions |
| [AGENTS.md](AGENTS.md) | AI agent guidelines for this codebase |
| [CLAUDE.md](CLAUDE.md) | Quick reference for Claude Code sessions |

---

## Directus CMS Collections

Content managed in Directus for AI responses and website:

| Collection | Purpose | Fields |
|------------|---------|--------|
| `products` | Internet plans & pricing | name, sku, category, price, speed_mbps, features |
| `faq` | Frequently asked questions | question, answer, category, business |
| `canned_responses` | AI response templates | trigger_keywords, response_template, category |
| `business_hours` | Operating schedules | business, day, open_time, close_time |
| `promotions` | Active deals & discounts | title, description, discount_percent, promo_code |

**Public API Access:**
- Products: `https://cms.ntpowergy.com/items/products`
- FAQ: `https://cms.ntpowergy.com/items/faq`
- Promotions: `https://cms.ntpowergy.com/items/promotions`

---

## Chatwoot Teams

Multi-department customer support structure:

```
                    SUPERVISORS
                  (Full oversight)
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
   SALES TEAM     SUPPORT TEAM    BILLING TEAM
   • New signups  • Tech issues   • Payments
   • Plan info    • Slow speeds   • Invoices
   • Upgrades     • Equipment     • Refunds
```

Teams are auto-assigned based on WhatsApp inbox routing.

---

## Database Schema

Automation tables in `netsurf` database:

| Table | Purpose |
|-------|---------|
| `leads` | WhatsApp/web lead captures |
| `bookings` | Nature Park reservations |
| `ticket_analytics` | Chatwoot ticket metrics |
| `daily_reports` | Archived daily reports |
| `products` | Solar/Starlink product catalog |
| `business_info` | Business contact details |

---

## Tech Stack

- **Orchestration**: Docker Compose
- **Workflow**: n8n (queue mode with workers)
- **CMS**: Directus 11
- **Support**: Chatwoot
- **Database**: PostgreSQL 15 with pgvector
- **Cache**: Redis 7
- **Tunnel**: Pangolin Newt

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

<div align="center">

**Built for Netsurf Group of Companies, Guyana**

</div>
