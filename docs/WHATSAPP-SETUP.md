# WhatsApp Business Cloud API Setup Guide

Complete step-by-step guide to connect WhatsApp to the Netsurf automation stack.

**Sources:**
- [Chatwoot WhatsApp Cloud API Docs](https://www.chatwoot.com/docs/product/channels/whatsapp/whatsapp-cloud)
- [Chatwoot Manual Setup Guide](https://www.chatwoot.com/hc/user-guide/articles/1756799850-how-to-setup-a-whats_app-channel-manual-flow)
- [Meta WhatsApp Developer Hub](https://business.whatsapp.com/developers/developer-hub)

---

## Prerequisites

Before starting, ensure you have:
- [ ] A Meta (Facebook) account
- [ ] Admin access to Chatwoot (https://chat.ntpowergy.com)
- [ ] Valid phone number(s) NOT already registered with WhatsApp
- [ ] Business verification documents (for full API access)

---

## Step 1: Create Meta Business Portfolio

### 1.1 Access Meta Business Suite

1. Go to **https://business.facebook.com**
2. Log in with your Facebook account
3. Click the dropdown menu under **Home**
4. Select **Create a business portfolio**

### 1.2 Complete Business Profile

Fill in all required fields:
- **Business name:** `Netsurf Group` (official registered name)
- **Business description:** Brief description of services
- **Business category:** Telecommunications or relevant category
- **Contact information:** Business address, phone, website
- **Business email:** Official business email

> Save your Business Portfolio ID - you'll need it later.

---

## Step 2: Create Facebook Developer App

### 2.1 Access Developer Console

1. Go to **https://developers.facebook.com**
2. Log in with the same Facebook account
3. Click **Create App** button

### 2.2 Configure New App

1. Select **Other** as the use case
2. Choose **Business** as the app type
3. Fill in:
   - **App name:** `Netsurf WhatsApp`
   - **Contact email:** Your business email
   - **Business portfolio:** Select the portfolio you created
4. Click **Create App**

---

## Step 3: Add WhatsApp Product

### 3.1 Add WhatsApp to Your App

1. From your app dashboard, scroll to **Add Products**
2. Find **WhatsApp** and click **Set up**
3. You'll be directed to WhatsApp Getting Started page

### 3.2 Business Verification (REQUIRED)

> **Important:** Without business verification, you're limited to 2 phone numbers and low message volume.

1. Go to **Business Settings** → **Security Center**
2. Click **Start Verification**
3. Submit required documents:
   - Business registration certificate
   - Tax ID / Business license
   - Utility bill or bank statement (address verification)
4. Wait for approval (1-3 business days)

---

## Step 4: Create System User & Generate Token

### 4.1 Create System User

1. Go to **Business Settings** → **Users** → **System Users**
2. Click **Add**
3. Configure:
   - **Name:** `Chatwoot Integration`
   - **Role:** `Admin`
4. Click **Create System User**

### 4.2 Assign App Permissions

1. Click on the system user you created
2. Click **Add Assets**
3. Select **Apps** → Your WhatsApp app
4. Grant **Full Control**
5. Click **Save Changes**

### 4.3 Generate Permanent Access Token

1. Click on the system user
2. Click **Generate New Token**
3. Select your app
4. Check these permissions:
   - `whatsapp_business_management`
   - `whatsapp_business_messaging`
   - `whatsapp_business_manage_events`
5. Click **Generate Token**
6. **COPY AND SAVE THIS TOKEN IMMEDIATELY** - it won't be shown again!

```
# Save this securely - example format:
WHATSAPP_ACCESS_TOKEN=EAAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Step 5: Configure WhatsApp Cloud API

### 5.1 Access API Setup

1. In your Facebook Developer app, go to **WhatsApp** → **API Setup**
2. You'll see:
   - Temporary access token (ignore - use permanent token from Step 4)
   - Phone Number ID
   - WhatsApp Business Account ID

### 5.2 Add Production Phone Number

1. Click **Add phone number**
2. Enter your business phone number with country code: `+592XXXXXXXX`
3. Choose verification method: **SMS** or **Voice call**
4. Enter the OTP code received
5. Set display name (e.g., `Netsurf Support`)

### 5.3 Note Your IDs

Record these values - you need them for Chatwoot:

| Field | Where to Find | Example |
|-------|---------------|---------|
| Phone Number ID | API Setup page | `123456789012345` |
| WhatsApp Business Account ID | API Setup page or URL | `987654321098765` |
| Access Token | Step 4.3 | `EAAxxxxx...` |

---

## Step 6: Connect to Chatwoot

### 6.1 Create WhatsApp Inbox

1. Log into Chatwoot: **https://chat.ntpowergy.com**
2. Go to **Settings** → **Inboxes**
3. Click **Add Inbox**
4. Select **WhatsApp**
5. Choose **WhatsApp Cloud** (not Twilio)

### 6.2 Enter Configuration

Fill in the form:

| Field | Value |
|-------|-------|
| **Inbox Name** | `Netsurf Sales` (or descriptive name) |
| **Phone Number** | `+592XXXXXXXX` (your number) |
| **Phone Number ID** | From Step 5.3 |
| **Business Account ID** | From Step 5.3 |
| **API Key** | Your permanent access token from Step 4.3 |

Click **Create WhatsApp Inbox**

### 6.3 Copy Webhook Details

After creation, Chatwoot displays:
- **Webhook URL:** `https://chat.ntpowergy.com/webhooks/whatsapp/+592XXXXXXXX`
- **Webhook Verify Token:** (auto-generated)

**Copy both values** - you need them for Step 7.

### 6.4 Add Team & Agents

1. In the inbox settings, click **Collaborators**
2. Add team members who should receive WhatsApp messages
3. Optionally assign to a Team (Sales Team, Support Team, etc.)

---

## Step 7: Configure Webhook in Meta

### 7.1 Set Webhook URL

1. Go to **Facebook Developer Console** → Your App → **WhatsApp** → **Configuration**
2. In the **Webhook** section, click **Edit**
3. Enter:
   - **Callback URL:** The Chatwoot webhook URL from Step 6.3
   - **Verify Token:** The token from Step 6.3
4. Click **Verify and Save**

### 7.2 Subscribe to Webhook Events

1. After verification, click **Manage** next to Webhook fields
2. Subscribe to these events:
   - ✅ `messages` (required - incoming messages)
   - ✅ `message_status` (optional - delivery receipts)
3. Click **Done**

---

## Step 8: Create Message Templates

> **Required for proactive messaging** - messages sent outside the 24-hour customer service window.

### 8.1 Access Template Manager

1. Go to **WhatsApp Manager** → **Account Tools** → **Message Templates**
2. Click **Create Template**

### 8.2 Create Required Templates

#### Template 1: Weekly Promotion

| Setting | Value |
|---------|-------|
| **Name** | `weekly_promo_v1` |
| **Category** | Marketing |
| **Language** | English |

**Body text:**
```
🎉 Special Offer from {{1}}!

{{2}}

Valid until {{3}}.

Reply to learn more or type STOP to unsubscribe.
```

#### Template 2: Service Outage Notification

| Setting | Value |
|---------|-------|
| **Name** | `outage_notification_v1` |
| **Category** | Utility |
| **Language** | English |

**Body text:**
```
⚠️ Service Alert from Netsurf

We're experiencing {{1}} in {{2}}.

Estimated resolution: {{3}}.

We apologize for the inconvenience. Reply AGENT for support.
```

#### Template 3: Payment Reminder

| Setting | Value |
|---------|-------|
| **Name** | `payment_reminder_v1` |
| **Category** | Utility |
| **Language** | English |

**Body text:**
```
💳 Payment Reminder from Netsurf

Hi {{1}}, your balance of {{2}} is due on {{3}}.

Pay now to avoid service interruption.

Need help? Reply AGENT.
```

### 8.3 Submit for Approval

1. Review each template for policy compliance
2. Click **Submit**
3. Templates are usually approved within minutes to 24 hours
4. Check status in the template list

---

## Step 9: Test the Integration

### 9.1 Send Test Message

1. From a **personal WhatsApp** (not the business number), send a message to your business number
2. Check Chatwoot - message should appear in the inbox within seconds
3. Reply from Chatwoot - reply should appear in WhatsApp

### 9.2 Verify AI Workflow (if configured)

1. Send: "What internet plans do you have?"
2. Check n8n executions at **https://n8n.ntpowergy.com**
3. Verify AI response is generated and sent

### 9.3 Test Escalation

1. Send: "I want to speak to an agent"
2. Verify escalation message appears
3. Verify conversation is unassigned (enters human queue)

---

## Step 10: Set Up Additional Numbers (Optional)

To add more WhatsApp numbers (e.g., separate for Support, Sales, Park):

1. **In Meta:** Add additional phone numbers in WhatsApp API Setup
2. **In Chatwoot:** Create a new inbox for each number (repeat Step 6)
3. **Webhook:** All numbers can share the same webhook configuration
4. **Teams:** Assign each inbox to the appropriate team

---

## Troubleshooting

### Messages Not Appearing in Chatwoot

| Check | How to Fix |
|-------|------------|
| Webhook URL correct? | Verify in Meta → WhatsApp → Configuration |
| Webhook verified? | Should show green checkmark |
| Events subscribed? | Must have `messages` subscribed |
| Token valid? | Regenerate if expired |

**Check logs:**
```bash
docker logs netsurf-chatwoot 2>&1 | grep -i whatsapp
```

### Can't Send Messages from Chatwoot

| Issue | Solution |
|-------|----------|
| "Message failed" | Check API token permissions |
| Outside 24h window | Use approved template instead |
| Phone not verified | Complete OTP verification in Meta |

### Webhook Verification Failing

1. Ensure Chatwoot URL is publicly accessible (not localhost)
2. Check SSL certificate is valid
3. Verify token matches exactly (no extra spaces)
4. Check Chatwoot is running: `docker ps | grep chatwoot`

### Template Rejected

Common rejection reasons:
- External URLs in marketing templates
- Missing `{{1}}` placeholder formatting
- Policy-violating content
- Misleading information

---

## Cost Information

WhatsApp charges per **24-hour conversation window**, not per message.

| Conversation Type | Trigger | Approx. Cost (USD) |
|-------------------|---------|-------------------|
| **Service** | Customer messages first | $0.005 - $0.02 |
| **Utility** | Templates (reminders, alerts) | $0.02 - $0.04 |
| **Marketing** | Templates (promos, sales) | $0.05 - $0.10 |

> Rates vary by country. Check [Meta Business rates](https://business.facebook.com) for Guyana pricing.

**Monthly estimate for Netsurf:**
- 500 support conversations: ~$10-25
- 100 promotional blasts: ~$10-25
- **Total: ~$20-50/month**

---

## Security Checklist

- [ ] Access token stored in environment variables (not in code)
- [ ] Webhook URL uses HTTPS
- [ ] System user has minimum required permissions
- [ ] Token rotation scheduled annually
- [ ] Business verification documents kept current

---

## Quick Reference

| Resource | URL |
|----------|-----|
| Meta Business Suite | https://business.facebook.com |
| Facebook Developers | https://developers.facebook.com |
| WhatsApp Manager | https://business.facebook.com/wa/manage |
| Chatwoot Admin | https://chat.ntpowergy.com |
| n8n Dashboard | https://n8n.ntpowergy.com |

| Configuration | Value |
|---------------|-------|
| Webhook Format | `https://chat.ntpowergy.com/webhooks/whatsapp/{phone_number}` |
| Required Permissions | `whatsapp_business_management`, `whatsapp_business_messaging` |
| Supported Media | Images, audio, video, documents |

---

## Next Steps After Setup

1. ✅ Train staff on Chatwoot inbox handling
2. ✅ Populate FAQ in Directus
3. ✅ Configure canned responses for quick replies
4. ✅ Set business hours for auto-responses
5. ✅ Monitor first week of conversations to tune AI
