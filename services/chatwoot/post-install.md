# Chatwoot Post-Installation Setup

## First Login

1. Navigate to http://localhost:3000 (or your domain)
2. Click "Create Account" (first visitor becomes super admin)
3. Fill in:
   - Name: Your admin name
   - Email: admin@netsurf.gy
   - Password: (strong password)
4. You're now logged in as super admin

## Initial Configuration

### 1. Create Agent Accounts

1. Go to **Settings** → **Agents**
2. Click **Add Agent**
3. For each staff member:
   - Name: Their full name
   - Email: Their work email
   - Role: Agent (or Administrator if they need full access)
4. They'll receive an email to set their password

### 2. Create Teams (Optional)

1. Go to **Settings** → **Teams**
2. Example teams:
   - **Sales** - Handle plan inquiries
   - **Support** - Handle technical issues
   - **Billing** - Handle payment questions

### 3. Create Inboxes (Channels)

#### WhatsApp Cloud API

1. Go to **Settings** → **Inboxes** → **Add Inbox**
2. Select **WhatsApp**
3. Choose **WhatsApp Cloud** (recommended)
4. You'll need:
   - Phone Number ID (from Meta Business)
   - Business Account ID
   - Access Token (from Meta Developer)
5. Follow Chatwoot's embedded signup or manual setup

**Official docs:** https://www.chatwoot.com/docs/product/channels/whatsapp/whatsapp-cloud

#### Facebook Messenger

1. Go to **Settings** → **Inboxes** → **Add Inbox**
2. Select **Messenger**
3. Click **Connect Facebook Page**
4. Login to Facebook and grant permissions
5. Select your Netsurf page

**Official docs:** https://www.chatwoot.com/docs/product/channels/facebook

#### Website Widget

1. Go to **Settings** → **Inboxes** → **Add Inbox**
2. Select **Website**
3. Configure:
   - Website Name: Netsurf
   - Domain: netsurf.gy
   - Widget Color: (your brand color)
4. Copy the embed script to your website

### 4. Configure Webhook to n8n

This connects Chatwoot to n8n for AI responses.

1. Go to **Settings** → **Integrations** → **Webhooks**
2. Click **Add Webhook**
3. Configure:
   - **Webhook URL:** `http://n8n:5678/webhook/chatwoot-webhook`
   - **Events:** Select `message_created`
4. Save

**Important:** Use `n8n` not `localhost` because they're on the same Docker network.

### 5. Disable Auto-Assignment (for bot to handle first)

1. Go to each inbox's settings
2. Under **Assignment**, set:
   - Auto-assignment: **Off** (let n8n handle initial response)
   - Or set to a specific "Bot" agent if you create one

## Get API Access Token

You'll need this for n8n to send messages back to Chatwoot.

1. Click your profile icon (top right)
2. Go to **Profile Settings**
3. Scroll to **Access Token**
4. Copy the token
5. Add to n8n as a credential

## Test the Setup

1. Send a test message from WhatsApp/Messenger
2. It should appear in Chatwoot inbox
3. The webhook should trigger n8n
4. Check n8n executions to verify

## Recommended Settings

### Auto-Resolve
- Settings → Account → Conversation Auto-Resolve
- Set to 24-48 hours for inactive conversations

### Canned Responses
Pre-written responses for common queries:
1. Go to **Settings** → **Canned Responses**
2. Add common responses like:
   - `/plans` - List of internet plans
   - `/hours` - Business hours
   - `/promo` - Current promotions

### Business Hours
1. Go to **Settings** → **Business Hours**
2. Configure your actual office hours
3. Set up auto-replies for out-of-hours messages

## Troubleshooting

### Messages not appearing
- Check webhook is configured correctly
- Verify WhatsApp/Facebook connection is active
- Check docker logs: `docker compose logs chatwoot-rails`

### Webhook not triggering
- Verify n8n is running
- Test webhook URL directly: `curl http://n8n:5678/webhook/chatwoot-webhook`
- Check n8n workflow is activated

### Agent can't login
- Verify SMTP is configured for password reset emails
- Admin can reset password manually in Settings → Agents
