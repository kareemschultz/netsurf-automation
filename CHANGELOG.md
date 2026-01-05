# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-01-05

### Added
- **n8n Workflow Templates** - 5 production-ready workflows:
  - `01-whatsapp-lead-capture.json` - Auto-categorize incoming leads by business
  - `02-booking-confirmation.json` - Nature Park reservations with pricing logic
  - `03-chatwoot-ticket-handler.json` - Auto-respond and escalate tickets
  - `04-mcp-server-tools.json` - AI agent business tools (6 tools exposed)
  - `05-daily-business-report.json` - 6 PM daily metrics report
- **Pangolin Newt Tunnel** - Reverse proxy configuration in `config/pangolin/docker-compose.yml`
- **Production Domains** configured:
  - `n8n.ntpowergy.com` - Workflow automation
  - `cms.ntpowergy.com` - Content management
  - `chat.ntpowergy.com` - Customer support
- **Database Tables** for automation:
  - `leads` - Customer inquiries with AI categorization
  - `bookings` - Nature Park reservations
  - `ticket_analytics` - Chatwoot metrics
  - `daily_reports` - Archived daily reports
  - `products` - Solar/Starlink catalog
  - `business_info` - Contact details and hours
- **MCP Integration** - Updated `.mcp.json` with n8n-mcp and netsurf-mcp servers
- **Documentation**:
  - `docs/N8N-SETUP.md` - Complete n8n configuration guide
  - Updated `README.md` with architecture, badges, service URLs
  - Updated `AGENTS.md` with project context and quick reference
- **Beads Issues** (NS-001 through NS-004) for task tracking

### Changed
- PostgreSQL image from `postgres:15-alpine` to `pgvector/pgvector:pg15` (Chatwoot vector support)
- Directus healthcheck to use Node.js http module (more reliable)
- Removed deprecated `version: '3.8'` from docker-compose.yml

### Fixed
- Chatwoot restart loop caused by stale PID file (added cleanup command)
- Directus healthcheck failing with wget (switched to Node.js)
- n8n workflow import - removed read-only `tags` field

### Security
- n8n API key stored in environment variables
- Chatwoot API credential configured via API
- Environment-based secret management
- Role-based access control for Directus
- API token scoping for minimum permissions

## [0.1.0] - 2026-01-04

### Added
- Initial release
- Core platform architecture
- Multi-business support (WISP, Power, Nature Park)
- WhatsApp Business API compliance
- AI confidence-based escalation system
