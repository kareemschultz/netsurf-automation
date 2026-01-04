# Official Documentation - USE THESE ONLY

⚠️ **CRITICAL:** Do not rely on training knowledge for configuration. Always fetch and verify from these official sources.

---

## 🐳 Docker

| Resource | URL |
|----------|-----|
| Docker Engine Install (Ubuntu) | https://docs.docker.com/engine/install/ubuntu/ |
| Docker Compose Install | https://docs.docker.com/compose/install/linux/ |
| Docker Compose Reference | https://docs.docker.com/compose/compose-file/ |
| Docker Networking | https://docs.docker.com/network/ |
| Docker Volumes | https://docs.docker.com/storage/volumes/ |

---

## 🔄 n8n

| Resource | URL |
|----------|-----|
| **n8n Docker Deployment** | https://docs.n8n.io/hosting/installation/docker/ |
| n8n Environment Variables | https://docs.n8n.io/hosting/configuration/environment-variables/ |
| n8n Queue Mode (Scaling) | https://docs.n8n.io/hosting/scaling/queue-mode/ |
| n8n API Reference | https://docs.n8n.io/api/api-reference/ |
| n8n MCP Server | https://www.npmjs.com/package/@n8n/n8n-mcp-server |
| n8n Webhook Node | https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/ |
| n8n HTTP Request Node | https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest/ |
| n8n Anthropic/Claude Node | https://docs.n8n.io/integrations/builtin/cluster-nodes/sub-nodes/n8n-nodes-langchain.lmchatanthropic/ |

---

## 📦 Directus

| Resource | URL |
|----------|-----|
| **Directus Docker Guide** | https://docs.directus.io/self-hosted/docker-guide.html |
| Directus Environment Variables | https://docs.directus.io/self-hosted/config-options.html |
| Directus API Reference | https://docs.directus.io/reference/introduction.html |
| Directus Items API | https://docs.directus.io/reference/items.html |
| Directus Collections API | https://docs.directus.io/reference/system/collections.html |
| Directus Permissions | https://docs.directus.io/configuration/users-roles-permissions.html |
| Directus Authentication | https://docs.directus.io/reference/authentication.html |

---

## 💬 Chatwoot

| Resource | URL |
|----------|-----|
| **Chatwoot Docker Deployment** | https://www.chatwoot.com/docs/self-hosted/deployment/docker |
| Chatwoot Environment Variables | https://www.chatwoot.com/docs/self-hosted/configuration/environment-variables |
| Chatwoot API Reference | https://www.chatwoot.com/developers/api/ |
| Chatwoot Webhooks | https://www.chatwoot.com/docs/product/features/webhooks |
| Chatwoot WhatsApp Setup | https://www.chatwoot.com/docs/product/channels/whatsapp/whatsapp-cloud |
| Chatwoot Facebook Setup | https://www.chatwoot.com/docs/product/channels/facebook |
| Chatwoot Captain AI | https://www.chatwoot.com/docs/product/features/captain |

---

## 🐘 PostgreSQL

| Resource | URL |
|----------|-----|
| PostgreSQL Docker Image | https://hub.docker.com/_/postgres |
| PostgreSQL Documentation | https://www.postgresql.org/docs/15/ |
| pg_dump Backup | https://www.postgresql.org/docs/15/app-pgdump.html |
| PostgreSQL MCP Server | https://github.com/modelcontextprotocol/servers/tree/main/src/postgres |

---

## 🔴 Redis

| Resource | URL |
|----------|-----|
| Redis Docker Image | https://hub.docker.com/_/redis |
| Redis Documentation | https://redis.io/docs/ |

---

## 🌐 Caddy (Reverse Proxy)

| Resource | URL |
|----------|-----|
| Caddy Docker | https://hub.docker.com/_/caddy |
| Caddy Documentation | https://caddyserver.com/docs/ |
| Caddyfile Reference | https://caddyserver.com/docs/caddyfile |
| Caddy Automatic HTTPS | https://caddyserver.com/docs/automatic-https |
| Caddy Reverse Proxy | https://caddyserver.com/docs/caddyfile/directives/reverse_proxy |

---

## 🤖 Claude/Anthropic API

| Resource | URL |
|----------|-----|
| Anthropic API Reference | https://docs.anthropic.com/en/api/getting-started |
| Claude Models | https://docs.anthropic.com/en/docs/about-claude/models |
| Messages API | https://docs.anthropic.com/en/api/messages |
| API Pricing | https://www.anthropic.com/pricing |

---

## 📱 WhatsApp Business API

| Resource | URL |
|----------|-----|
| WhatsApp Cloud API | https://developers.facebook.com/docs/whatsapp/cloud-api |
| WhatsApp Business Policy | https://www.whatsapp.com/legal/business-policy |
| WhatsApp Pricing | https://developers.facebook.com/docs/whatsapp/pricing |
| Meta Business Suite | https://business.facebook.com/ |

---

## 📘 Facebook/Instagram API

| Resource | URL |
|----------|-----|
| Facebook Graph API | https://developers.facebook.com/docs/graph-api |
| Facebook Pages API | https://developers.facebook.com/docs/pages-api |
| Instagram Content Publishing | https://developers.facebook.com/docs/instagram-api/guides/content-publishing |
| Instagram Rate Limits | https://developers.facebook.com/docs/instagram-api/overview#rate-limiting |

---

## 🔧 MCP (Model Context Protocol)

| Resource | URL |
|----------|-----|
| MCP Specification | https://modelcontextprotocol.io/ |
| MCP Servers List | https://github.com/modelcontextprotocol/servers |
| PostgreSQL MCP | https://github.com/modelcontextprotocol/servers/tree/main/src/postgres |
| Filesystem MCP | https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem |
| n8n MCP Server | https://www.npmjs.com/package/@n8n/n8n-mcp-server |

---

## 🛠️ Troubleshooting Resources

| Issue | Resource |
|-------|----------|
| Docker container won't start | Check `docker compose logs <service>` |
| Port already in use | `sudo lsof -i :<port>` then kill process |
| Out of memory | `docker stats` to see usage, increase VPS RAM |
| SSL certificate issues | https://caddyserver.com/docs/automatic-https#troubleshooting |
| Chatwoot migration fails | https://www.chatwoot.com/docs/self-hosted/deployment/docker#running-migrations |
| n8n webhook not receiving | https://docs.n8n.io/hosting/configuration/environment-variables/#webhook |

---

## 📋 Version Pinning

Use these specific versions for stability:

| Service | Image/Version | Notes |
|---------|---------------|-------|
| PostgreSQL | `postgres:15-alpine` | LTS, well-tested |
| Redis | `redis:7-alpine` | Current stable |
| n8n | `n8nio/n8n:latest` | Or pin to specific like `1.70.0` |
| Directus | `directus/directus:11` | Major version 11 |
| Chatwoot | `chatwoot/chatwoot:latest` | Or pin to `v3.x.x` |
| Caddy | `caddy:2-alpine` | Current stable |

---

## 🔍 How Claude Code Should Use These Docs

1. **Before configuring a service:** Fetch its environment variables page
2. **Before writing API calls:** Fetch the API reference
3. **On any error:** Check the troubleshooting section of that service's docs
4. **For integration:** Check both services' docs (e.g., Chatwoot webhooks + n8n webhooks)

Example workflow:
```
1. Need to configure n8n queue mode
2. Fetch: https://docs.n8n.io/hosting/scaling/queue-mode/
3. Apply documented environment variables
4. Verify with health check
```
