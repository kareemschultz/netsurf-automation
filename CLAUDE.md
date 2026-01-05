# Netsurf Automation - Claude Code Instructions

## Project Overview
Customer communications automation stack for Netsurf WISP (Guyana ISP).
- **n8n**: Workflow automation (port 5678)
- **Chatwoot**: Customer inbox (port 3000)
- **Directus**: Content CMS (port 8055)
- **PostgreSQL/Redis**: Data stores

## Issue Tracking (Beads)

This project uses `bd` (beads) for issue tracking synced to git.

### Essential Commands
```bash
bd list                    # View all issues
bd ready                   # Show ready-to-work tasks
bd show <id>               # View issue details
bd create "Title" -p P1    # Create issue (P0-P4 priority)
bd update <id> --status in_progress
bd close <id> --reason "Done"
bd sync                    # Sync to GitHub (ALWAYS run after changes)
```

### Workflow
1. `bd list` - Check available tasks
2. `bd update <id> --status in_progress` - Start working
3. Do the work, commit code
4. `bd close <id> --reason "what was done"` - Mark complete
5. `bd sync` - Push to GitHub

## Docker Commands
```bash
# From /home/kareem/netsurf-automation/config/docker/
docker compose ps                    # Check status
docker compose logs -f <service>     # View logs
docker compose restart <service>     # Restart service
```

## Key Files
- `config/docker/docker-compose.yml` - Stack definition
- `config/docker/.env` - Environment variables (secrets)
- `workflows/` - n8n workflow JSON files
- `.beads/issues.jsonl` - Issue tracking data

## Git Workflow
```bash
# After code changes
git add -A && git commit -m "type: description"
git push

# After issue changes
bd sync
```

## Services
| Service | Internal | External |
|---------|----------|----------|
| n8n | localhost:5678 | https://n8n.ntpowergy.com |
| Directus | localhost:8055 | https://cms.ntpowergy.com |
| Chatwoot | localhost:3000 | https://chat.ntpowergy.com |

## Important Notes
- WhatsApp policy: Bot must only handle Netsurf queries, offer human escalation
- Always run `bd sync` after closing/updating issues
- Check `docs/CLAUDE-CODE.md` for detailed instructions
