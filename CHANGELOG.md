# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure with organized directories
- Docker Compose stack for all services (n8n, Directus, Chatwoot, PostgreSQL, Redis)
- Deployment scripts (00-05) for automated setup
- n8n workflow: Inbound Message Triage with AI responses
- n8n workflow: Social Media Auto-Poster
- Claude system prompt for Netsurf-specific responses
- Directus schema for multi-business content management
- Chatwoot integration guides
- MCP server configuration for AI agent access
- Pangolin reverse proxy route configuration
- GitHub Actions CI/CD pipelines
- Issue templates for bugs, features, and tasks
- Speckit specifications for core features
- Beads initialization for AI task tracking
- Comprehensive documentation suite

### Security
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
