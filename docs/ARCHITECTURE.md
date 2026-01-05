# Architecture Overview

## System Architecture

```
                              EXTERNAL SERVICES
    ┌────────────────────────────────────────────────────────────┐
    │  WhatsApp Cloud API    Facebook Graph API    Claude API   │
    │  Instagram API         Meta Business Manager              │
    └─────────────────────────────┬──────────────────────────────┘
                                  │
                          ════════╧════════
                               PANGOLIN
                          (Reverse Proxy/SSL)
                          ════════╤════════
                                  │
    ┌─────────────────────────────┼─────────────────────────────┐
    │                    DOCKER NETWORK                          │
    │  ┌──────────────────────────┼────────────────────────────┐ │
    │  │                          │                            │ │
    │  │   ┌──────────────┐   ┌───┴───────────┐   ┌─────────┐ │ │
    │  │   │   CHATWOOT   │   │     N8N       │   │DIRECTUS │ │ │
    │  │   │   (Port 3000)│──▶│  (Port 5678)  │◀──│ (8055)  │ │ │
    │  │   │              │   │               │   │         │ │ │
    │  │   │  - WhatsApp  │   │  - Workflows  │   │  - CMS  │ │ │
    │  │   │  - Facebook  │   │  - Webhooks   │   │  - API  │ │ │
    │  │   │  - Instagram │   │  - Scheduler  │   │  - Logs │ │ │
    │  │   │  - Web Chat  │   │               │   │         │ │ │
    │  │   └──────┬───────┘   └───────┬───────┘   └────┬────┘ │ │
    │  │          │                   │                │      │ │
    │  │          └───────────────────┼────────────────┘      │ │
    │  │                              │                       │ │
    │  │   ┌──────────────────────────┴───────────────────┐   │ │
    │  │   │               POSTGRESQL 15                   │   │ │
    │  │   │  ┌─────────┐ ┌─────────┐ ┌─────────────────┐ │   │ │
    │  │   │  │   n8n   │ │directus │ │    chatwoot     │ │   │ │
    │  │   │  │   db    │ │   db    │ │       db        │ │   │ │
    │  │   │  └─────────┘ └─────────┘ └─────────────────┘ │   │ │
    │  │   └──────────────────────────────────────────────┘   │ │
    │  │                              │                       │ │
    │  │   ┌──────────────────────────┴───────────────────┐   │ │
    │  │   │                  REDIS 7                      │   │ │
    │  │   │        (Caching, Queues, Sessions)            │   │ │
    │  │   └──────────────────────────────────────────────┘   │ │
    │  │                                                      │ │
    │  └──────────────────────────────────────────────────────┘ │
    └────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Inbound Message Flow

```
Customer sends message (WhatsApp/FB/IG/Web)
         │
         ▼
┌─────────────────┐
│    CHATWOOT     │ ◀── Receives and classifies by inbox
└────────┬────────┘
         │ webhook POST
         ▼
┌─────────────────┐
│      N8N        │ ◀── Workflow: 01-inbound-message-triage
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌───────┐
│DIRECTUS│ │CLAUDE │ ◀── Fetch context, generate response
└───┬───┘ └───┬───┘
    │         │
    └────┬────┘
         ▼
┌─────────────────┐
│      N8N        │ ◀── Log conversation, check confidence
└────────┬────────┘
         │
    ┌────┴────────────┐
    ▼                 ▼
┌───────┐      ┌───────────┐
│CHATWOOT│      │ ESCALATE  │
│(respond)│     │ (if needed)│
└────────┘      └───────────┘
```

### 2. Social Media Posting Flow

```
Schedule triggers (Mon/Thu 9AM)
         │
         ▼
┌─────────────────┐
│      N8N        │ ◀── Workflow: 02-social-media-auto-poster
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    DIRECTUS     │ ◀── Fetch active promotions
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     CLAUDE      │ ◀── Generate platform-specific captions
└────────┬────────┘
         │
    ┌────┼────────────────┐
    ▼    ▼                ▼
┌──────┐┌──────┐    ┌─────────┐
│  FB  ││  IG  │    │ TikTok  │
│ API  ││ API  │    │ (email) │
└──┬───┘└──┬───┘    └────┬────┘
   │       │             │
   └───────┼─────────────┘
           ▼
┌─────────────────┐
│    DIRECTUS     │ ◀── Log results to social_post_logs
└─────────────────┘
```

## Service Responsibilities

| Service | Responsibility | Data Owned |
|---------|---------------|------------|
| **Chatwoot** | Customer messaging, channel management | Conversations, contacts |
| **n8n** | Workflow orchestration, scheduling | Workflow definitions, credentials |
| **Directus** | Content management, logging | Business content, logs |
| **PostgreSQL** | Data persistence | All structured data |
| **Redis** | Caching, job queues | Session data, queues |
| **Pangolin** | Reverse proxy, SSL termination | Route config, certificates |

## Security Layers

```
┌─────────────────────────────────────────────────┐
│                   INTERNET                       │
└─────────────────────────┬───────────────────────┘
                          │
                    ┌─────▼─────┐
                    │ FIREWALL  │ ◀── UFW: Allow 80, 443 only
                    └─────┬─────┘
                          │
                    ┌─────▼─────┐
                    │ PANGOLIN  │ ◀── SSL/TLS termination
                    └─────┬─────┘
                          │
              ┌───────────┼───────────┐
              ▼           ▼           ▼
         ┌────────┐ ┌────────┐ ┌────────┐
         │ n8n    │ │Directus│ │Chatwoot│ ◀── Auth required
         │ (Auth) │ │ (Auth) │ │ (Auth) │
         └────────┘ └────────┘ └────────┘
                          │
              ┌───────────┴───────────┐
              ▼                       ▼
         ┌────────┐             ┌────────┐
         │Postgres│             │ Redis  │ ◀── Internal network only
         └────────┘             └────────┘
```

## Multi-WhatsApp Number Architecture

The system supports multiple WhatsApp Business numbers for different departments with hybrid routing.

```
                     META BUSINESS ACCOUNT
    ┌─────────────────────────────────────────────────┐
    │  +592-XXX-1111    +592-XXX-2222    +592-XXX-3333│
    │     (Sales)        (Support)        (Billing)   │
    └─────────┬──────────────┬──────────────┬─────────┘
              │              │              │
              │      Webhook (unified URL)  │
              └──────────────┼──────────────┘
                             ▼
    ┌─────────────────────────────────────────────────┐
    │                      N8N                         │
    │  ┌─────────────────────────────────────────────┐│
    │  │  WhatsApp Lead Capture Workflow              ││
    │  │  - Extract display_phone_number              ││
    │  │  - Route based on department                 ││
    │  │  - Tag conversation accordingly              ││
    │  └─────────────────────────────────────────────┘│
    └─────────────────────────┬───────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   CHATWOOT   │     │   CHATWOOT   │     │   CHATWOOT   │
│ Inbox: Sales │     │Inbox: Support│     │Inbox: Billing│
└──────┬───────┘     └──────┬───────┘     └──────┬───────┘
       │                    │                    │
       ▼                    ▼                    ▼
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Sales Team  │     │Support Team  │     │ Shared Pool  │
│ (Dedicated)  │     │ (Dedicated)  │     │  (Hybrid)    │
└──────────────┘     └──────────────┘     └──────────────┘
       │                    │                    │
       └────────────────────┼────────────────────┘
                            ▼
                   ┌──────────────┐
                   │ Supervisors  │ ◀── Can see all inboxes
                   └──────────────┘
```

### Routing Logic

| Incoming Number | Chatwoot Inbox | Primary Team | Escalation |
|-----------------|----------------|--------------|------------|
| Sales line | sales-whatsapp | Sales Team | Any available |
| Support line | support-whatsapp | Support Team | Technical leads |
| Billing line | billing-whatsapp | Shared Pool | Accounts team |

### Webhook Payload Identification

```json
{
  "entry": [{
    "changes": [{
      "value": {
        "metadata": {
          "display_phone_number": "+592XXXXXXXX",
          "phone_number_id": "123456789"
        },
        "messages": [...]
      }
    }]
  }]
}
```

The `display_phone_number` field identifies which business number received the message, enabling proper routing.

## Scaling Considerations

### Horizontal Scaling

- **n8n**: Add workers via `n8n-worker` containers
- **Chatwoot**: Scale Sidekiq workers for job processing
- **PostgreSQL**: Read replicas for reporting queries

### Vertical Scaling

| Service | Recommended | Minimum |
|---------|-------------|---------|
| PostgreSQL | 2GB RAM | 512MB |
| Redis | 512MB RAM | 128MB |
| n8n | 1GB RAM | 512MB |
| Directus | 512MB RAM | 256MB |
| Chatwoot | 2GB RAM | 1GB |
| **Total** | 6-8GB RAM | 4GB |

## High Availability (Future)

```
                    ┌─────────────┐
                    │ Load Balancer│
                    └──────┬──────┘
                           │
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
    ┌─────────┐       ┌─────────┐       ┌─────────┐
    │ Node 1  │       │ Node 2  │       │ Node 3  │
    │ (Active)│       │ (Active)│       │ (Standby)│
    └────┬────┘       └────┬────┘       └────┬────┘
         │                 │                 │
         └─────────────────┼─────────────────┘
                           ▼
                    ┌─────────────┐
                    │ PostgreSQL  │
                    │  Primary    │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    ▼             ▼
               ┌────────┐   ┌────────┐
               │Replica 1│   │Replica 2│
               └────────┘   └────────┘
```
