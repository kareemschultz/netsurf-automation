# Project Tracking

This document provides an overview of project tracking systems used in Netsurf Automation.

## Tracking Systems

### 1. GitHub Issues & Projects

**Primary tracking for human collaboration**

- **Issues**: Bug reports, feature requests, tasks
- **Project Board**: Kanban-style workflow tracking
- **Labels**: Categorization and prioritization

#### Label Reference

| Label | Purpose |
|-------|---------|
| `epic` | Large initiative (multiple tasks) |
| `task` | Individual work item |
| `bug` | Something broken |
| `enhancement` | New feature |
| `docs` | Documentation |
| `infra` | Infrastructure/DevOps |
| `priority:high` | Urgent |
| `priority:medium` | Normal |
| `priority:low` | Can wait |

### 2. Beads (`.beads/`)

**AI agent task tracking**

Beads provides a structured, queryable task graph for AI coding agents.

```bash
# Initialize (already done)
bd init

# Create task
bd add "Implement feature X"

# List ready tasks (no blockers)
bd ready

# Complete task
bd done <task-id>
```

**Why Beads?**
- Distributed, git-backed storage
- Dependency-aware task management
- AI agents can programmatically create/update tasks
- Survives context window limits

### 3. Speckit Specifications (`docs/specs/`)

**Formal requirements documentation**

Specifications define the "what" before implementation:

| Spec | Topic |
|------|-------|
| SPEC-001 | Inbound Message Triage |
| SPEC-002 | Social Media Auto-Posting |
| SPEC-003 | Multi-Business Routing |

**Spec Structure:**
- Overview & Objectives
- Functional Requirements (FR-XXX)
- Non-Functional Requirements (NFR-XXX)
- Data Models
- Acceptance Criteria

## Current Epics

### Infrastructure & Deployment
- [ ] Docker Compose stack
- [ ] Deployment scripts
- [ ] Pangolin routes
- [ ] SSL certificates
- [ ] Backup system

### n8n Workflows
- [ ] Inbound message triage
- [ ] Social media auto-poster
- [ ] Credential configuration
- [ ] Webhook integration

### Directus CMS
- [ ] Schema creation
- [ ] Collection setup
- [ ] Roles & permissions
- [ ] Seed data

### Chatwoot Integration
- [ ] WhatsApp channel
- [ ] Facebook Messenger
- [ ] Webhook to n8n
- [ ] Canned responses

### MCP Configuration
- [ ] Server installation
- [ ] API access
- [ ] Connectivity testing

### Documentation
- [ ] Deployment guide
- [ ] Architecture docs
- [ ] Troubleshooting guide
- [ ] API reference

## Workflow

1. **Create Issue** - Use templates for consistency
2. **Add to Project** - Assign to board column
3. **Create Beads Task** - For AI agent visibility
4. **Implement** - Branch from main
5. **PR & Review** - Link to issue
6. **Merge** - Closes issue automatically
7. **Update Beads** - Mark task complete

## Progress Metrics

Track these weekly:
- Open issues by priority
- Issues closed this week
- Average time to close
- Beads tasks ready vs blocked
