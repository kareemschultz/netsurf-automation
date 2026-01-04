# Troubleshooting Guide

## Quick Diagnostics

Run the troubleshooting script:

```bash
./scripts/troubleshoot.sh
```

## Common Issues

### 1. Services Not Starting

**Symptom:** Containers exit immediately or fail health checks

**Check:**
```bash
# View all container statuses
docker compose ps

# Check specific container logs
docker compose logs -f chatwoot-rails
docker compose logs -f n8n
docker compose logs -f directus
```

**Common Causes:**
- Missing `.env` file - Run `./scripts/01-generate-secrets.sh`
- Port conflicts - Check with `netstat -tlnp | grep -E '3000|5678|8055'`
- Insufficient memory - Check with `free -h`

### 2. Database Connection Errors

**Symptom:** "Connection refused" or "ECONNREFUSED"

**Check:**
```bash
# Verify PostgreSQL is running
docker compose exec postgres pg_isready -U netsurf

# Check PostgreSQL logs
docker compose logs postgres
```

**Solutions:**
- Wait for PostgreSQL to fully start (can take 30-60 seconds)
- Verify database credentials in `.env`
- Check if databases exist: `docker compose exec postgres psql -U netsurf -l`

### 3. Webhook Not Triggering

**Symptom:** Chatwoot messages don't trigger n8n workflow

**Check:**
```bash
# Test webhook endpoint
curl -X POST http://localhost:5678/webhook/chatwoot-webhook \
  -H "Content-Type: application/json" \
  -d '{"event":"message_created","content":"test"}'

# Check n8n executions
docker compose logs -f n8n | grep webhook
```

**Solutions:**
- Verify webhook URL in Chatwoot settings
- Use internal Docker network URL: `http://netsurf-n8n:5678/webhook/...`
- Check n8n workflow is activated

### 4. AI Responses Not Working

**Symptom:** No AI response or generic error messages

**Check n8n workflow execution:**
1. Go to n8n UI → Executions
2. Find failed execution
3. Check error details on Claude node

**Common Causes:**
- Invalid Anthropic API key
- API rate limits exceeded
- Directus token expired
- Network connectivity issues

**Solutions:**
```bash
# Test Claude API directly
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: YOUR_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{"model":"claude-3-haiku-20240307","max_tokens":100,"messages":[{"role":"user","content":"Hello"}]}'
```

### 5. Social Media Posts Failing

**Symptom:** Posts not appearing on Facebook/Instagram

**Check:**
- Meta API token validity (expires periodically)
- Page/Account permissions
- n8n execution logs for API errors

**Solutions:**
1. Regenerate Meta access token
2. Verify page publishing permissions
3. Check Instagram business account connection

### 6. High Memory Usage

**Symptom:** Server becomes slow, OOM errors

**Check:**
```bash
# View container resource usage
docker stats --no-stream

# Check system memory
free -h
```

**Solutions:**
```bash
# Restart heavy services
docker compose restart chatwoot-rails chatwoot-sidekiq

# Clear Redis cache if needed
docker compose exec redis redis-cli FLUSHALL

# Reduce log retention
docker compose logs --tail=0
```

### 7. SSL/HTTPS Issues

**Symptom:** Certificate errors or "Not Secure" warnings

**Check Pangolin configuration:**
- Certificate paths correct
- Domain DNS resolving to server IP
- Ports 80/443 accessible from internet

**Solutions:**
- Force certificate renewal
- Check firewall allows ports 80/443
- Verify DNS propagation: `dig +short n8n.netsurf.gy`

### 8. WhatsApp Messages Not Sending

**Symptom:** Chatwoot shows "failed to send"

**Check:**
- WhatsApp Cloud API credentials
- Phone number verification status
- Message template approval (for 24h+ conversations)

**Solutions:**
1. Verify in Meta Business Manager
2. Check WhatsApp message limits
3. Use approved templates for old conversations

## Log Locations

| Service | Log Command |
|---------|-------------|
| All services | `docker compose logs` |
| PostgreSQL | `docker compose logs postgres` |
| n8n | `docker compose logs n8n` |
| Directus | `docker compose logs directus` |
| Chatwoot | `docker compose logs chatwoot-rails` |
| Sidekiq | `docker compose logs chatwoot-sidekiq` |

## Health Check Endpoints

| Service | Endpoint | Expected |
|---------|----------|----------|
| n8n | `http://localhost:5678/healthz` | 200 OK |
| Directus | `http://localhost:8055/server/health` | 200 OK |
| Chatwoot | `http://localhost:3000/api` | 200/401 |
| PostgreSQL | `pg_isready` | 0 exit code |
| Redis | `redis-cli ping` | PONG |

## Emergency Recovery

### Full Stack Restart

```bash
docker compose down
docker compose up -d
./scripts/04-health-check.sh
```

### Database Restore

```bash
# Stop services
docker compose stop n8n directus chatwoot-rails chatwoot-sidekiq

# Restore backup
gunzip -c backups/latest.sql.gz | docker compose exec -T postgres psql -U netsurf

# Restart services
docker compose start n8n directus chatwoot-rails chatwoot-sidekiq
```

### Factory Reset (Data Loss!)

```bash
# WARNING: Destroys all data
docker compose down -v
rm config/docker/.env
./scripts/01-generate-secrets.sh
./scripts/02-deploy-stack.sh
./scripts/03-run-migrations.sh
```

## Getting Help

1. Check this guide first
2. Run `./scripts/troubleshoot.sh`
3. Review service logs
4. Open GitHub issue with logs attached
