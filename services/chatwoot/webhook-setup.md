# Chatwoot ↔ n8n Webhook Integration

## Overview

The integration works as follows:

```
Customer sends message
       ↓
Chatwoot receives it
       ↓
Chatwoot sends webhook to n8n
       ↓
n8n processes with AI
       ↓
n8n sends response back via Chatwoot API
       ↓
Customer receives response
```

## Step 1: Configure Chatwoot Webhook

### In Chatwoot Admin

1. Go to **Settings** → **Integrations** → **Webhooks**
2. Click **Add new webhook**
3. Fill in:
   - **Webhook URL:** `http://n8n:5678/webhook/chatwoot-webhook`
   - **Events:** Check `message_created`
4. Click **Add Webhook**

### Webhook Payload Example

When a message arrives, Chatwoot sends this to n8n:

```json
{
  "event": "message_created",
  "id": 12345,
  "message_type": "incoming",
  "content": "What internet plans do you have?",
  "content_type": "text",
  "created_at": "2026-01-04T10:30:00Z",
  "conversation": {
    "id": 100,
    "status": "open",
    "contact_inbox": {
      "contact_id": 50,
      "inbox_id": 1
    }
  },
  "sender": {
    "id": 50,
    "name": "John Customer",
    "email": null,
    "phone_number": "+592XXXXXXX"
  },
  "inbox": {
    "id": 1,
    "name": "WhatsApp",
    "channel_type": "Channel::Whatsapp"
  },
  "account": {
    "id": 1,
    "name": "Netsurf"
  }
}
```

## Step 2: Configure n8n Workflow

The workflow `01-inbound-message-triage.json` is pre-configured. It needs:

### Credentials to Add

1. **Anthropic API**
   - Go to n8n → Credentials → Add → Anthropic
   - Paste your Claude API key

2. **Directus API Token**
   - Go to n8n → Credentials → Add → Header Auth
   - Name: `Directus API Token`
   - Header: `Authorization`
   - Value: `Bearer YOUR_DIRECTUS_TOKEN`

3. **Chatwoot API Token**
   - Go to n8n → Credentials → Add → Header Auth
   - Name: `Chatwoot API Token`
   - Header: `api_access_token`
   - Value: Your token from Chatwoot Profile

### Environment Variables to Set

In n8n settings or docker-compose.yml:

```
DIRECTUS_URL=http://directus:8055
CHATWOOT_URL=http://chatwoot-rails:3000
CHATWOOT_ACCOUNT_ID=1
```

## Step 3: Sending Responses Back

n8n sends responses using Chatwoot's API:

```bash
POST /api/v1/accounts/{account_id}/conversations/{conversation_id}/messages

Headers:
  api_access_token: YOUR_TOKEN
  Content-Type: application/json

Body:
{
  "content": "Here are our internet plans...",
  "message_type": "outgoing",
  "private": false
}
```

This is already configured in the workflow.

## Step 4: Testing

### Test 1: Verify Webhook Connectivity

```bash
# From the VPS
curl -X POST http://localhost:5678/webhook/chatwoot-webhook \
  -H "Content-Type: application/json" \
  -d '{
    "event": "message_created",
    "message_type": "incoming",
    "content": "test message",
    "conversation": {"id": 1, "contact_inbox": {"contact_id": 1}},
    "inbox": {"channel_type": "test"},
    "sender": {"name": "Test"}
  }'
```

Should return: `{"status": "processed"}` or similar.

### Test 2: Check n8n Execution

1. Go to n8n → Executions
2. You should see the test execution
3. Check for errors in the execution details

### Test 3: Full Flow

1. Send a message to your WhatsApp/Messenger
2. Check it appears in Chatwoot
3. Check n8n executes
4. Verify AI response is sent back

## Troubleshooting

### Webhook not receiving

**Check Chatwoot webhook config:**
- Settings → Integrations → Webhooks → Edit
- Verify URL is exactly `http://n8n:5678/webhook/chatwoot-webhook`

**Check n8n workflow is active:**
- Green toggle should be ON
- Workflow should be saved

**Check network:**
```bash
# From Chatwoot container
docker compose exec chatwoot-rails curl http://n8n:5678/healthz
```

### n8n can't reach Chatwoot

**Check internal network:**
```bash
docker compose exec n8n wget -qO- http://chatwoot-rails:3000/api
```

**Check URL format:**
- Use `chatwoot-rails` not `localhost`
- Use port `3000`

### AI not responding

**Check Claude API key:**
- Verify key in n8n credentials
- Check API key has credits

**Check Directus:**
- Verify Directus is running
- Check collections have data
- Test API: `curl http://localhost:8055/items/internet_plans`

### Double responses

**If both AI and human respond:**
- Check escalation logic in workflow
- Ensure bot doesn't reply to its own messages
- Filter `message_type: "incoming"` only

## Security Considerations

### Validate Webhook Source

Add this check at the start of your n8n workflow:

```javascript
// In a Code node
const sourceIP = $input.first().json.headers?.['x-forwarded-for'];
// Validate it's coming from Chatwoot container
```

### Rate Limiting

Consider adding rate limiting to prevent abuse:
- Chatwoot has built-in rate limits
- n8n queue mode handles burst traffic
- Monitor execution counts

### Token Security

- Never log full API tokens
- Use n8n credentials, not hardcoded values
- Rotate tokens periodically
