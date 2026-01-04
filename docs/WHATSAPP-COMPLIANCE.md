# ⚠️ Critical: WhatsApp Policy Compliance & Known Gotchas

**Updated:** January 2026  
**Source:** Gemini + ChatGPT review of architecture

---

## 🚨 WhatsApp Business Policy Change (Jan 15, 2026)

### What's Happening

WhatsApp has updated its Business Messaging Policy to **ban "general-purpose" AI chatbots**. This affects how you build the Netsurf bot.

**Sources:**
- WhatsApp Business Messaging Policy
- TechCrunch / AP News reporting on enforcement timeline

### What This Means for Netsurf

| ❌ NOT Allowed | ✅ Allowed |
|----------------|------------|
| "Ask me anything" chatbot | Scoped business bot (sales/support/info) |
| Marketing as "ChatGPT on WhatsApp" | "Netsurf Automated Assistant" |
| No human escalation path | Clear escalation ("Type AGENT") |
| Open-ended conversations | Structured flows (plan inquiry, support, etc.) |

### How We're Compliant

The workflow templates I created include:

1. **Strict System Prompt** - Claude is told it ONLY handles Netsurf services
2. **Forced Escalation Triggers** - Billing disputes, complaints, uncertainty → human
3. **Human Request Detection** - Keywords like "agent", "human", "help me" → immediate handoff
4. **Explicit Bot Disclosure** - "You are Netsurf's automated assistant" (not pretending to be human)
5. **Response Footer** - Every AI message includes: "Type AGENT for human help"

### Action Items

- [ ] Don't call it "AI chatbot" in marketing - call it "Netsurf Automated Support"
- [ ] Train Netsurf staff on escalation handling
- [ ] Monitor WhatsApp policy updates quarterly
- [ ] Keep conversation scope tight (plans, promos, basic support only)

---

## 💰 WhatsApp Pricing Reality

### Conversation-Based Billing

WhatsApp doesn't charge per-message. They charge per **24-hour conversation window**.

| Conversation Type | Trigger | Approx. Cost |
|------------------|---------|--------------|
| **Service** | Customer initiates | $0.005 - $0.02 |
| **Utility** | Order updates, confirmations | $0.02 - $0.04 |
| **Marketing** | Promotions, sales | $0.05 - $0.10 |
| **Authentication** | OTP, verification | $0.03 - $0.05 |

*Prices vary by country. Check Meta Business rates for Guyana.*

### Real Cost Scenarios

| Scenario | Conversations/Month | Est. Cost |
|----------|---------------------|-----------|
| 100 support inquiries | 100 service | ~$2-5 |
| 500 support inquiries | 500 service | ~$10-25 |
| Promo blast to 1,000 customers | 1,000 marketing | ~$50-100 |
| Promo blast to 5,000 customers | 5,000 marketing | ~$250-500 |

### Budget Advice for Netsurf

- **Support conversations** are cheap - don't worry about these
- **Marketing blasts** cost real money - budget accordingly
- **Alternative:** Use email/social for mass promos, WhatsApp for personalized follow-ups
- **Tip:** Opening a service convo and then sending a promo within 24h = still service rate

---

## 📋 WhatsApp Template Requirement (CRITICAL FOR PROMOS)

### The Problem

Outside the 24-hour conversation window, you **CANNOT send free-form messages**. Meta requires **Pre-Approved Message Templates**.

| Scenario | Can Send Free Text? | What's Needed |
|----------|---------------------|---------------|
| Customer messages first | ✅ Yes (24h) | Nothing |
| Reply within 24h | ✅ Yes | Nothing |
| Weekly promo blast | ❌ NO | Approved Template |
| Follow-up after 24h silence | ❌ NO | Approved Template |
| Outage notification to all | ❌ NO | Approved Template |

### Required Templates to Create

Before going live with promos, create these in **Meta Business Manager → WhatsApp Manager → Message Templates**:

#### 1. `weekly_promo_v1` (Marketing)
```
🎉 Special Offer from {{1}}!

{{2}}

Valid until {{3}}.
Reply to learn more or type STOP to unsubscribe.
```

#### 2. `outage_notification_v1` (Utility)
```
⚠️ Service Alert from {{1}}

We're experiencing {{2}} in {{3}}.
Estimated resolution: {{4}}.

We apologize for the inconvenience.
```

#### 3. `appointment_reminder_v1` (Utility)
```
📅 Reminder from {{1}}

Your {{2}} is scheduled for {{3}}.
Reply CONFIRM or RESCHEDULE.
```

#### 4. `payment_reminder_v1` (Utility)
```
💳 Payment Reminder from {{1}}

Your balance of {{2}} is due on {{3}}.
Pay now to avoid service interruption.

Need help? Reply AGENT.
```

### How to Create Templates

1. Go to **Meta Business Manager** → **WhatsApp Manager**
2. Click **Message Templates** → **Create Template**
3. Choose category (Marketing = promos, Utility = alerts/reminders)
4. Fill in template with `{{1}}`, `{{2}}` placeholders
5. Submit for review (usually approved in 5 mins - 24 hours)
6. Note the exact **template name** - n8n needs this

### Using Templates in n8n

```javascript
// n8n HTTP Request node to WhatsApp Cloud API
{
  "messaging_product": "whatsapp",
  "to": "{{$json.phone_number}}",
  "type": "template",
  "template": {
    "name": "weekly_promo_v1",
    "language": { "code": "en" },
    "components": [
      {
        "type": "body",
        "parameters": [
          { "type": "text", "text": "Netsurf" },
          { "type": "text", "text": "50% off first 3 months!" },
          { "type": "text", "text": "January 31, 2026" }
        ]
      }
    ]
  }
}
```

**Important:** The n8n workflow for promo blasts MUST use this template format, not plain text.

---

## 🧠 AI Confidence Gate (PREVENTS HALLUCINATIONS)

### Why This Matters

Without confidence checking, Claude might:
- Invent plan prices that don't exist
- Promise coverage in areas Netsurf doesn't serve
- Give wrong troubleshooting steps

### How It Works

The n8n workflow requires Claude to return structured JSON:

```json
{
  "answer": "Our Basic plan is 10 Mbps for GYD $5,000/month...",
  "confidence": 0.92,
  "sources": ["wisp_plans:basic", "wisp_faq:pricing"],
  "needs_human": false,
  "reasoning": "Direct match in plans table for speed and price"
}
```

### Escalation Rules (Configured in Workflow)

| Condition | Action |
|-----------|--------|
| `confidence < 0.75` | → Escalate to human |
| `sources` is empty | → Escalate to human |
| Same question asked 2x | → Escalate to human |
| `needs_human: true` | → Escalate to human |
| Turn count > 6 | → Escalate to human |
| Billing/payment dispute | → Escalate to human |

### Staff Control (Directus → System Controls)

Staff can adjust without developer:
- `confidence_threshold` - Default 0.75, increase for stricter
- `max_turns_before_escalate` - Default 6
- `bot_enabled` - Kill switch if AI goes haywire

---

## 🛡️ Hard Scope Guardrail

### Topics AI MUST Refuse

The Claude system prompt explicitly blocks these:

| Blocked Topic | Why |
|---------------|-----|
| Legal advice | Liability |
| Financial/investment advice | Liability |
| Medical advice | Liability |
| Competitor comparisons | Legal + PR risk |
| Political topics | PR risk |
| Personal opinions | Off-brand |
| Anything non-Netsurf | Policy compliance |

### Refusal Response Template

```
I can only help with Netsurf services (internet, solar, and nature park).

For [legal/financial/medical] questions, please consult a qualified professional.

Is there anything about our services I can help with? Or type AGENT for human assistance.
```

---

## 🎵 TikTok API Limitations

### The Problem

TikTok's Content Posting API has strict requirements:
- App review process
- Business verification
- Content approval workflows
- Rate limits

### Our Solution

The social media workflow generates TikTok captions but **doesn't auto-post**. Instead:

1. AI generates caption + hashtags
2. Workflow logs to Directus `social_post_logs` table
3. Email sent to staff with caption
4. Staff manually posts to TikTok

### Future Options

If Netsurf wants full TikTok automation later:
- **Ayrshare** (~$29/mo) - Multi-platform posting API
- **Buffer** (~$15/mo) - With TikTok integration
- **Later** (~$25/mo) - Instagram + TikTok scheduling

---

## 🖥️ Infrastructure Gotchas

### Single Point of Failure Risk

**The Problem:** Everything on one VPS. If n8n goes haywire, it could crash Chatwoot.

**Mitigations in docker-compose.yml:**
1. n8n runs in queue mode (worker separate from main process)
2. Each service has its own database
3. Health checks configured

**Better for Production:**
- Use 6-8GB RAM VPS (not 4GB)
- OR use managed PostgreSQL (Supabase, DigitalOcean Managed DB)
- Set up monitoring (Uptime Kuma, Zabbix agent, Netdata)

### Memory Recommendations

| Setup | RAM | Notes |
|-------|-----|-------|
| Testing | 2GB | Minimum, may crash under load |
| Small production | 4GB | Okay for <1000 convos/day |
| **Recommended** | 6-8GB | Comfortable headroom |
| High volume | 16GB+ | Or split to multiple VPS |

### Backup Strategy (Day 1!)

Add this to crontab:

```bash
# Daily database backup at 2 AM
0 2 * * * docker compose -f /opt/netsurf-stack/docker-compose.yml exec -T postgres pg_dumpall -U netsurf | gzip > /opt/backups/netsurf-db-$(date +\%Y\%m\%d).sql.gz

# Keep only last 7 days
0 3 * * * find /opt/backups -name "netsurf-db-*.sql.gz" -mtime +7 -delete
```

---

## 📊 Instagram API Limits

### Content Publishing Limits

Instagram has strict rate limits for API-published content:

- **100 API-published posts per 24-hour rolling window**
- Per account, not per app
- Includes photos, videos, reels, carousels

### Our Approach

The workflow only posts promos (2x/week max), well under limits. But if Netsurf wants to post more:

- Don't post more than 10/day via API
- Use Instagram's native app for additional content
- Buffer/Later can help manage queuing

---

## 🔒 Security Checklist

### Before Going Live

- [ ] All passwords in `.env` are strong (24+ chars, random)
- [ ] Directus admin isn't using default password
- [ ] n8n basic auth is enabled
- [ ] Chatwoot SMTP is configured (password reset needs email)
- [ ] SSL/TLS enabled via Caddy
- [ ] Firewall only allows 80, 443 (close 5678, 8055, 3000 externally)
- [ ] API tokens are scoped to minimum permissions

### API Token Hygiene

| Service | Token Location | Rotation Schedule |
|---------|----------------|-------------------|
| Anthropic (Claude) | n8n credentials | Annual or on exposure |
| Directus | n8n credentials | Annual |
| Chatwoot | n8n credentials | Annual |
| Facebook/Meta | n8n credentials | 60 days (short-lived) or use long-lived |
| WhatsApp | Chatwoot config | Per Meta requirements |

---

## 🎯 The 6 Core Workflows (80% of Value)

Per ChatGPT's review, focus on these first:

| # | Workflow | Status |
|---|----------|--------|
| 1 | **Inbound Message Triage** | ✅ Created |
| 2 | **Social Media Auto-Poster** | ✅ Created |
| 3 | Plan & Pricing Explainer | Part of #1 |
| 4 | Tech Support Playbook | Part of #1 |
| 5 | Lead Capture & Follow-up | TODO (Phase 2) |
| 6 | Outage Notification Broadcast | TODO (Phase 2) |

---

## 📈 Conversation Logging for Prompt Refinement

The `conversation_logs` table in Directus captures every AI interaction. 

**Monthly Review Process:**

1. Export last month's logs
2. Filter to `escalated = true` (AI couldn't handle)
3. Analyze patterns - what questions stump the AI?
4. Update FAQ in Directus with missing answers
5. Refine Claude system prompt if needed

**Metrics to Track:**

- Escalation rate (target: <20%)
- Response time (target: <5 seconds)
- Customer satisfaction (via follow-up survey)
- Conversations per day

---

## 🛡️ "Escalation by Design" Principle

WhatsApp policy + good CX both require robust human handoff.

### Escalation Triggers (Built into Workflow)

| Trigger | Why |
|---------|-----|
| Customer types "agent", "human", etc. | Explicit request |
| AI responds with "ESCALATE_TO_HUMAN" | AI uncertainty |
| Billing/payment keywords | Policy sensitive |
| Angry sentiment detected | CX recovery |
| 3+ back-and-forth without resolution | Loop prevention |
| Complex technical issue | Beyond playbook |

### What Happens on Escalation

1. AI sends: "I'm connecting you with a team member..."
2. Conversation unassigned in Chatwoot (enters human queue)
3. Chatwoot notifies available agents
4. Human sees full conversation history
5. Human takes over seamlessly

---

## 🔧 Operational Hardening

### n8n Retry & Fallback Logic

Configure these in n8n workflows:

**HTTP Request Node Settings:**
```
Retry on Fail: Yes
Max Retries: 3
Wait Between Retries: 1000ms
Continue on Fail: Yes (for critical paths)
Timeout: 30000ms (30 seconds)
```

**Dead Letter Queue Pattern:**
Create a "Failed Messages" workflow that:
1. Receives failed webhook payloads
2. Logs to Directus `failed_messages` table
3. Alerts staff via email
4. Attempts retry after 1 hour

### Graceful Degradation Messages

When AI/API fails, send these fallback messages:

| Failure | Response |
|---------|----------|
| Claude timeout | "Thanks for reaching out! We're experiencing high volume. A team member will respond within 30 minutes." |
| Claude error | "I'm having a technical issue. Let me connect you with a human. Type AGENT for immediate help." |
| Directus unreachable | "One moment, I'm looking that up... A team member will follow up shortly." |
| Rate limited | "We're receiving many messages right now. Your question is queued and we'll respond within 1 hour." |

### Security Hardening

1. **Directus Roles:**
   - `AI Bot` role: Read-only on content, write-only on logs
   - `Staff` role: Read/write content, read-only logs
   - `Admin`: Full access

2. **API Token Scopes:**
   - Chatwoot token: Only what's needed for messaging
   - Directus token: Scoped to specific collections
   - Never commit tokens to git

3. **Firewall:**
   ```bash
   # Only expose via Pangolin
   sudo ufw deny 5678  # n8n
   sudo ufw deny 8055  # Directus
   sudo ufw deny 3000  # Chatwoot
   sudo ufw allow 80
   sudo ufw allow 443
   ```

### Logging Limits (Prevents Disk Crash)

Already configured in docker-compose.yml:
```yaml
logging:
  driver: "json-file"
  options:
    max-size: "10m"  # 10MB per log file
    max-file: "3"    # Keep 3 rotations
```

This caps logs at 30MB per container, auto-rotating.

### Backup Strategy

**Daily automated backup (in crontab):**
```bash
0 2 * * * /opt/netsurf-comms/scripts/backup.sh >> /var/log/netsurf-backup.log 2>&1
```

**Weekly restore test:**
Schedule 10 minutes monthly to:
1. Download backup file
2. Spin up test database
3. Verify data integrity
4. Document in ops log

**Offsite backup (recommended):**
Add to backup.sh:
```bash
# After local backup
rclone copy /opt/backups/latest.sql.gz backblaze:netsurf-backups/
```

---

## ✅ Pre-Launch Checklist

### Infrastructure
- [ ] VPS provisioned (6-8GB RAM recommended)
- [ ] Docker + Docker Compose installed
- [ ] Domain DNS configured
- [ ] SSL working via Pangolin
- [ ] Firewall configured (block direct app ports)

### Stack Deployment
- [ ] docker-compose.yml deployed
- [ ] All services healthy (`docker compose ps`)
- [ ] Chatwoot migrations run
- [ ] Can login to all 3 admin panels
- [ ] Logging limits in place

### Directus Setup
- [ ] All collections created (16 tables)
- [ ] Sample data populated
- [ ] **System Controls** singleton configured
- [ ] **Decision Rules** populated
- [ ] Staff role configured (read/write content)
- [ ] AI Bot role configured (read content, write logs only)
- [ ] API tokens generated

### n8n Setup
- [ ] Anthropic credentials added
- [ ] Directus credentials added
- [ ] Chatwoot credentials added
- [ ] Facebook/Meta credentials added (if using)
- [ ] Both workflows imported
- [ ] Workflows tested manually
- [ ] Retry settings configured (3 retries, 30s timeout)
- [ ] Error notifications enabled

### Chatwoot Setup
- [ ] WhatsApp Cloud API connected
- [ ] **WhatsApp Templates** created and approved in Meta
- [ ] Facebook Messenger connected
- [ ] Website widget configured
- [ ] n8n webhook added (`http://netsurf-n8n:5678/webhook/chatwoot-webhook`)
- [ ] Agent accounts created
- [ ] Teams configured (optional)

### Testing
- [ ] Send test WhatsApp message → AI responds
- [ ] Type "agent" → escalation works
- [ ] Ask about plans → correct info from Directus
- [ ] Test low-confidence scenario → escalates properly
- [ ] Toggle `bot_enabled=false` → AI stops responding
- [ ] Toggle `emergency_mode=true` → emergency message appears
- [ ] Manual workflow trigger → social posts work
- [ ] Logs appearing in `conversation_logs` table
- [ ] Check `daily_metrics` populating

### Go Live
- [ ] Staff trained on Chatwoot inbox handling
- [ ] Staff trained on Directus content updates
- [ ] Staff shown **System Controls** kill switches
- [ ] Backup cron configured and tested
- [ ] Restore procedure documented and tested
- [ ] Monitoring set up (Uptime Kuma/Zabbix)
- [ ] Netsurf informed of WhatsApp conversation costs
- [ ] WhatsApp Template workflow explained to marketing
- [ ] Emergency contact list for system issues documented
- [ ] Post-launch check scheduled (24h, 1 week, 1 month)

---

## 📈 Post-Launch Monitoring

### Daily Checks (Automated via n8n)
- AI resolution rate > 70%
- Average confidence > 0.8
- No error spikes in logs
- Disk space > 20% free

### Weekly Review
- Check `top_unanswered_questions` → Add to FAQ
- Check `top_escalation_reasons` → Improve prompts
- Review conversation samples for quality
- Update decision rules if needed

### Monthly Tasks
- Rotate API keys
- Test backup restore
- Review WhatsApp costs
- Update content (plans, promos, FAQ)
- Check for n8n/Chatwoot/Directus updates
