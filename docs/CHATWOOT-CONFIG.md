# Chatwoot Configuration Reference

Complete configuration for Netsurf customer support platform.

## Access

- **URL**: https://chat.ntpowergy.com
- **Account ID**: 1

## Teams

| Team | ID | Purpose | Auto-Assign |
|------|-----|---------|-------------|
| Sales Team | 1 | New inquiries, signups, upgrades | Yes |
| Support Team | 2 | Technical issues, troubleshooting | Yes |
| Billing Team | 3 | Payments, invoices, accounts | Yes |
| Supervisors | 4 | Escalations, oversight | No |

## Labels

### Business Labels
| Label | Color | Purpose |
|-------|-------|---------|
| `wisp` | Blue | Internet service inquiries |
| `power` | Orange | Solar and Starlink inquiries |
| `park` | Green | Nature park bookings |

### Priority Labels
| Label | Color | Purpose |
|-------|-------|---------|
| `urgent` | Red | High priority, immediate attention |
| `vip` | Purple | VIP customer |
| `new-customer` | Cyan | Potential signup |

### Issue Type Labels
| Label | Color | Purpose |
|-------|-------|---------|
| `billing` | Gray | Payment/invoice related |
| `technical` | Sky Blue | Technical support needed |
| `installation` | Violet | New installation request |
| `complaint` | Red | Customer complaint |

## Canned Responses

Type `/` followed by the shortcode to use:

| Shortcode | Purpose |
|-----------|---------|
| `/greeting` | Welcome message with menu options |
| `/plans` | Internet plans and pricing |
| `/escalate` | Transfer to human agent |
| `/troubleshoot` | Basic troubleshooting steps |
| `/payment` | Payment options and methods |
| `/solar` | Solar products and services |
| `/starlink` | Starlink information |
| `/park` | Nature park pricing and booking |

## Custom Attributes

### Contact Attributes
| Attribute | Type | Description |
|-----------|------|-------------|
| Account Number | Text | Customer account number |
| Internet Plan | List | Current plan (Basic/Standard/Premium/Business/None) |
| Location | Text | Customer address or area |
| Customer Type | List | Residential/Business/Prospect/VIP |
| Service Start Date | Date | When service began |

### Conversation Attributes
| Attribute | Type | Description |
|-----------|------|-------------|
| Issue Category | List | Billing/Technical/Sales/Installation/General |
| Resolution | Text | How the issue was resolved |
| Ticket Number | Text | External ticket reference |

## Automation Rules

Auto-labeling is configured for:

1. **Urgent Messages** - Keywords: urgent, emergency, asap, immediately, critical → `urgent` label
2. **Billing Inquiries** - Keywords: bill, payment, invoice, pay, balance, due → `billing` label
3. **Technical Issues** - Keywords: slow, not working, down, no internet, problem → `technical` label
4. **Solar Inquiries** - Keywords: solar, panel, battery, inverter, starlink → `power` label
5. **Park Inquiries** - Keywords: park, cabin, camping, reservation, book → `park` label

## Webhook Configuration

For n8n integration:

```
Webhook URL: https://n8n.ntpowergy.com/webhook/chatwoot-webhook
Events: message_created, conversation_status_changed
```

## WhatsApp Inbox (Pending)

After completing Meta Developer setup:

1. Go to Settings → Inboxes → Add Inbox
2. Select WhatsApp → WhatsApp Cloud
3. Enter:
   - Inbox Name: `Netsurf WhatsApp`
   - Phone: `+592 644 6840`
   - Phone Number ID: `<from Meta>`
   - Business Account ID: `<from Meta>`
   - API Key: `<permanent access token>`

## API Access

```bash
# Get API token from Profile → Access Token
API_TOKEN="your-api-token"

# Example: List conversations
curl -H "api_access_token: $API_TOKEN" \
  https://chat.ntpowergy.com/api/v1/accounts/1/conversations
```

## Staff Training

See [STAFF-TRAINING-GUIDE.md](training/STAFF-TRAINING-GUIDE.md) for:
- Using canned responses effectively
- Label and routing best practices
- Escalation procedures
- WhatsApp response guidelines
