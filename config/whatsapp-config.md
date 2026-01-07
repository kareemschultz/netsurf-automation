# WhatsApp Business Cloud API Configuration

Quick reference for Netsurf WhatsApp integration.

## Phone Number Assignments

| Business | Main Phone | WhatsApp Number | Purpose |
|----------|------------|-----------------|---------|
| Netsurf WISP/Power | +592 644 7847 | +592 644 6840 | Customer support & sales |
| Netsurf Nature Park | +592 611 9443 | +592 611 9443 | Reservations & bookings |
| Secondary Line | +592 621 8271 | - | Backup/overflow |

## Meta Configuration (Fill after setup)

```bash
# From Meta Developer Console → WhatsApp → API Setup
WHATSAPP_PHONE_NUMBER_ID=<get from meta>
WHATSAPP_BUSINESS_ACCOUNT_ID=<get from meta>
WHATSAPP_ACCESS_TOKEN=<generate permanent token>
```

## Chatwoot Configuration

After getting Meta credentials, create inbox in Chatwoot:

1. Go to: https://chat.ntpowergy.com/app/accounts/1/settings/inboxes
2. Click "Add Inbox" → "WhatsApp" → "WhatsApp Cloud"
3. Enter:
   - **Inbox Name**: `Netsurf WhatsApp`
   - **Phone Number**: `+592 644 6840`
   - **Phone Number ID**: `<from meta>`
   - **Business Account ID**: `<from meta>`
   - **API Key**: `<permanent access token>`

## Webhook Configuration

After Chatwoot inbox creation, configure in Meta:

- **Callback URL**: `https://chat.ntpowergy.com/webhooks/whatsapp/+5926446840`
- **Verify Token**: `<provided by Chatwoot after inbox creation>`
- **Subscribe Events**: `messages`, `message_status`

## Teams Assignment

| Team | ID | Purpose |
|------|----|---------|
| Sales Team | 1 | New inquiries, signups |
| Support Team | 2 | Technical issues |
| Billing Team | 3 | Payment questions |
| Supervisors | 4 | Escalations |

## Status Checklist

- [ ] Meta Business Portfolio created
- [ ] Meta Developer App created
- [ ] WhatsApp product added to app
- [ ] System User created with permissions
- [ ] Permanent access token generated
- [ ] Phone number added and verified
- [ ] Chatwoot inbox created
- [ ] Webhook configured in Meta
- [ ] Test message sent/received
- [ ] n8n workflow activated
