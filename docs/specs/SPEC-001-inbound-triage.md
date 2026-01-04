# SPEC-001: Inbound Message Triage

**Status:** Draft
**Author:** Netsurf Team
**Created:** 2026-01-04
**Last Updated:** 2026-01-04

## Overview

This specification defines the requirements for the inbound message triage system, which processes customer messages and generates AI-powered responses.

## Objectives

1. Automatically process incoming customer messages from all channels
2. Generate contextual AI responses using Claude
3. Escalate to human agents when appropriate
4. Log all interactions for quality review

## Functional Requirements

### FR-001: Message Reception

- **FR-001.1**: System SHALL receive messages via Chatwoot webhook
- **FR-001.2**: System SHALL process messages from WhatsApp, Facebook, Instagram, and web chat
- **FR-001.3**: System SHALL filter outgoing messages (process incoming only)
- **FR-001.4**: System SHALL extract: message content, sender info, conversation ID, channel type

### FR-002: Business Detection

- **FR-002.1**: System SHALL detect business context from channel/inbox assignment
- **FR-002.2**: System SHALL detect business from keywords (solar, cabin, internet, etc.)
- **FR-002.3**: System SHALL route to correct Directus collections based on business
- **FR-002.4**: Default to Netsurf WISP if business cannot be determined

### FR-003: AI Response Generation

- **FR-003.1**: System SHALL call Claude API with business-specific context
- **FR-003.2**: System SHALL use claude-3-haiku for standard queries (cost optimization)
- **FR-003.3**: System SHALL use claude-3-sonnet for complex/angry customer scenarios
- **FR-003.4**: System SHALL include active plans, promotions, and FAQs in context
- **FR-003.5**: Claude SHALL return structured JSON with confidence score

### FR-004: Confidence Gating

- **FR-004.1**: If confidence < 0.75, System SHALL escalate to human
- **FR-004.2**: If `needs_human` flag is true, System SHALL escalate
- **FR-004.3**: If sources array is empty, System SHALL escalate
- **FR-004.4**: System SHALL log low-confidence queries for FAQ improvement

### FR-005: Escalation Triggers

System SHALL escalate when customer message contains:
- **FR-005.1**: "agent", "human", "person", "help me" (explicit request)
- **FR-005.2**: "cancel", "refund", "billing", "payment" (financial keywords)
- **FR-005.3**: "complaint", "angry", "terrible", "worst" (sentiment keywords)
- **FR-005.4**: Conversation exceeds 6 turns without resolution

### FR-006: Response Delivery

- **FR-006.1**: System SHALL post response to Chatwoot via API
- **FR-006.2**: System SHALL include escalation notice when transferring to human
- **FR-006.3**: Response SHALL include "Type AGENT for human help" footer
- **FR-006.4**: System SHALL handle API failures gracefully with fallback message

### FR-007: Logging

- **FR-007.1**: System SHALL log all interactions to Directus `conversation_logs`
- **FR-007.2**: Log SHALL include: message, response, confidence, channel, timestamp
- **FR-007.3**: Log SHALL include escalation reason if escalated
- **FR-007.4**: Logs SHALL be queryable for analytics

## Non-Functional Requirements

### NFR-001: Performance

- Response time SHALL be < 5 seconds for 95% of queries
- System SHALL handle 100 concurrent conversations

### NFR-002: Availability

- System SHALL have 99.5% uptime
- System SHALL provide fallback message during API outages

### NFR-003: Security

- API tokens SHALL be stored in environment variables
- System SHALL not log sensitive customer data (credit cards, passwords)

### NFR-004: Compliance

- System SHALL comply with WhatsApp Business Policy
- System SHALL never impersonate a human
- System SHALL always offer human escalation option

## Data Model

### Input (Chatwoot Webhook)

```json
{
  "event": "message_created",
  "message_type": "incoming",
  "content": "string",
  "conversation": { "id": "number" },
  "sender": { "id": "number", "name": "string" },
  "inbox": { "id": "number", "channel_type": "string" }
}
```

### Output (Claude Response)

```json
{
  "answer": "string",
  "confidence": "number (0.0-1.0)",
  "sources": ["string"],
  "needs_human": "boolean",
  "reasoning": "string"
}
```

## Acceptance Criteria

- [ ] Messages from all channels are processed
- [ ] AI responses are contextually accurate
- [ ] Low-confidence responses are escalated
- [ ] Explicit human requests are honored
- [ ] All conversations are logged
- [ ] Response time meets SLA
- [ ] WhatsApp policy compliance verified

## Dependencies

- Chatwoot (message source)
- n8n (workflow orchestration)
- Directus (content/logging)
- Claude API (AI responses)
