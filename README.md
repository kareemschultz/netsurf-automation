# Netsurf Automation

AI-powered customer communications platform for the Netsurf Group of Companies.

## Overview

This platform unifies customer support and social media automation across the Netsurf businesses in Guyana:

- **Netsurf Power** - Solar energy solutions & Starlink satellite internet kits
  - Solar panels, lithium batteries, hybrid inverters
  - Starlink equipment sales and installation
  - Off-grid power systems
  - Contact: +592-6446840 / 6119443 / 6218271
  - Location: 56 Chalmers Place, Georgetown

- **Netsurf Nature Park** - Eco-tourism retreat in Linden
  - Day trips and overnight cabin stays
  - Nature experiences, camping, birdwatching
  - Reservations: +592-611-9443 / 621-8271

## Architecture

```
Customer Channels                    Backend Services
+-----------------+                 +------------------+
| WhatsApp        |                 |    Chatwoot      |
| Facebook        +---------------->|  (Omnichannel)   |
| Instagram       |                 +--------+---------+
| Web Chat        |                          |
+-----------------+                          | webhook
                                             v
+------------------+              +----------+----------+
|    Directus      |<------------>|        n8n         |
|  (CMS/Content)   |   context    | (Workflow Engine)  |
+------------------+              +----------+----------+
                                             |
                                             v
                                  +----------+----------+
                                  |     Claude API      |
                                  |  (AI Intelligence)  |
                                  +---------------------+
```

## Features

- **Multi-Business Routing** - Automatic detection routes customers to correct knowledge base
- **AI Confidence Gating** - Low confidence responses escalate to humans
- **Structured Logging** - All conversations logged for analysis
- **Social Media Automation** - AI-generated posts for Facebook & Instagram
- **WhatsApp Compliant** - Meets Meta's business messaging policies

## Quick Start

### Prerequisites

- Docker & Docker Compose v2
- 6-8GB RAM (4GB minimum)
- 20GB+ free disk space
- Ports 80, 443 available

### Deployment

```bash
# Clone repository
git clone https://github.com/kareemschultz/netsurf-automation.git
cd netsurf-automation

# Run deployment scripts in order
./scripts/00-preflight-check.sh    # Validate system
./scripts/01-generate-secrets.sh   # Generate credentials
./scripts/02-deploy-stack.sh       # Start containers
./scripts/03-run-migrations.sh     # Initialize databases
./scripts/04-health-check.sh       # Verify services
./scripts/05-import-workflows.sh   # Import n8n workflows
```

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for detailed instructions.

## Project Structure

```
netsurf-automation/
├── config/                 # Configuration files
│   ├── docker/             # Docker Compose & env
│   ├── mcp/                # MCP server configs
│   └── pangolin/           # Reverse proxy routes
├── docs/                   # Documentation
│   └── specs/              # Speckit specifications
├── scripts/                # Deployment automation
├── services/               # Service-specific setup
│   ├── chatwoot/           # Customer support platform
│   └── directus/           # CMS configuration
└── src/
    ├── database/           # SQL schemas & seeds
    ├── prompts/            # Claude system prompts
    └── workflows/          # n8n workflow JSONs
```

## Services

| Service | Purpose | Port |
|---------|---------|------|
| n8n | Workflow orchestration | 5678 |
| Directus | Content management | 8055 |
| Chatwoot | Customer messaging | 3000 |
| PostgreSQL | Database | 5432 |
| Redis | Cache/Queue | 6379 |

## Documentation

- [Deployment Guide](docs/DEPLOYMENT.md)
- [Architecture Overview](docs/ARCHITECTURE.md)
- [WhatsApp Compliance](docs/WHATSAPP-COMPLIANCE.md)
- [API Reference](docs/API-REFERENCE.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## Project Tracking

This project uses multiple tracking systems:

- **GitHub Issues** - Feature requests, bugs, tasks
- **GitHub Projects** - Kanban board for sprint planning
- **Beads** (`.beads/`) - AI agent task tracking
- **Speckit** (`docs/specs/`) - Formal specifications

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Branch naming conventions
- Commit message format
- Pull request process

## License

MIT License - see [LICENSE](LICENSE) for details.

## Acknowledgments

Built for the Netsurf Group of Companies, Guyana.
