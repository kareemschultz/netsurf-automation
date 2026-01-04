# SPEC-003: Multi-Business Routing

**Status:** Draft
**Author:** Netsurf Team
**Created:** 2026-01-04
**Last Updated:** 2026-01-04

## Overview

This specification defines the requirements for routing customer interactions to the correct business context within the Netsurf Group.

## Objectives

1. Accurately detect which business a customer is inquiring about
2. Route queries to correct knowledge base
3. Maintain content isolation between businesses
4. Support future business additions

## Business Entities

### Netsurf WISP

- **Domain:** Internet service provider
- **Keywords:** internet, plan, speed, router, wifi, connection, mbps, outage, bandwidth
- **Products:** Residential & business internet plans

### Netsurf Power

- **Domain:** Solar energy systems
- **Keywords:** solar, panel, battery, inverter, starlink, power, energy, installation, backup
- **Products:** Solar panels, batteries, inverters, installation services

### Netsurf Nature Park

- **Domain:** Eco-tourism resort
- **Keywords:** cabin, booking, park, nature, camping, activities, reservation, trip
- **Products:** Accommodations, activities, day passes

## Functional Requirements

### FR-001: Channel-Based Detection

- **FR-001.1**: System SHALL detect business from Chatwoot inbox assignment
- **FR-001.2**: Each business SHOULD have dedicated inbox(es)
- **FR-001.3**: Inbox naming convention: `{Channel}-{Business}` (e.g., "WhatsApp-WISP")

### FR-002: Keyword-Based Detection

- **FR-002.1**: System SHALL analyze message content for business keywords
- **FR-002.2**: Detection priority: Channel > Keywords > Default
- **FR-002.3**: Multiple keyword matches SHALL use highest-confidence match
- **FR-002.4**: System SHALL handle mixed queries (e.g., "internet and solar")

### FR-003: Phone Number Detection

- **FR-003.1**: System MAY detect business from WhatsApp number used
- **FR-003.2**: Each business MAY have dedicated WhatsApp number
- **FR-003.3**: Phone mapping SHALL be configurable in environment

### FR-004: Content Isolation

- **FR-004.1**: Each business SHALL have separate Directus collections:
  - WISP: `wisp_plans`, `wisp_faq`
  - Power: `power_products`, `power_services`, `power_faq`
  - Park: `park_accommodations`, `park_activities`, `park_faq`
- **FR-004.2**: AI queries SHALL only use collections for detected business
- **FR-004.3**: Shared collections: `promotions`, `business_info`

### FR-005: Context Injection

- **FR-005.1**: System SHALL inject business name into Claude system prompt
- **FR-005.2**: System SHALL only fetch relevant product/service data
- **FR-005.3**: System SHALL include business-specific contact info

### FR-006: Default Behavior

- **FR-006.1**: If business cannot be detected, default to Netsurf WISP
- **FR-006.2**: System SHALL log undetected queries for review
- **FR-006.3**: AI MAY ask clarifying question if highly ambiguous

### FR-007: Cross-Business Queries

- **FR-007.1**: For cross-business queries, System SHALL acknowledge all businesses
- **FR-007.2**: System SHALL provide basic info for each mentioned business
- **FR-007.3**: System MAY suggest contacting specific business directly

## Detection Algorithm

```
function detectBusiness(message, inbox):
  // Priority 1: Channel/Inbox assignment
  if inbox.name contains "WISP":
    return WISP
  if inbox.name contains "Power":
    return POWER
  if inbox.name contains "Park":
    return PARK

  // Priority 2: Keyword analysis
  keywords = extractKeywords(message)
  scores = {
    WISP: countMatches(keywords, WISP_KEYWORDS),
    POWER: countMatches(keywords, POWER_KEYWORDS),
    PARK: countMatches(keywords, PARK_KEYWORDS)
  }

  if max(scores) > threshold:
    return keyWithMaxScore(scores)

  // Priority 3: Default
  return WISP
```

## Data Model

### Business Configuration

```json
{
  "businesses": [
    {
      "id": "wisp",
      "name": "Netsurf WISP",
      "keywords": ["internet", "plan", "speed", "router"],
      "collections": ["wisp_plans", "wisp_faq"],
      "contact": {
        "phone": "+592-XXX-XXXX",
        "email": "support@netsurf.gy"
      }
    },
    {
      "id": "power",
      "name": "Netsurf Power",
      "keywords": ["solar", "battery", "panel", "inverter"],
      "collections": ["power_products", "power_services", "power_faq"],
      "contact": {
        "phone": "+592-XXX-XXXX",
        "email": "solar@netsurf.gy"
      }
    },
    {
      "id": "park",
      "name": "Netsurf Nature Park",
      "keywords": ["cabin", "booking", "park", "camping"],
      "collections": ["park_accommodations", "park_activities", "park_faq"],
      "contact": {
        "phone": "+592-XXX-XXXX",
        "email": "bookings@netsurf.gy"
      }
    }
  ]
}
```

### Routing Decision Log

```json
{
  "conversation_id": "number",
  "message_preview": "string (50 chars)",
  "detected_business": "wisp|power|park",
  "detection_method": "channel|keyword|default",
  "confidence": "number (0.0-1.0)",
  "keywords_found": ["string"],
  "timestamp": "datetime"
}
```

## Acceptance Criteria

- [ ] Channel-based detection works for all inboxes
- [ ] Keyword detection correctly identifies business
- [ ] Default routing works when detection fails
- [ ] Content isolation is maintained
- [ ] Cross-business queries are handled gracefully
- [ ] Detection decisions are logged
- [ ] New business can be added via configuration

## Dependencies

- Chatwoot (inbox configuration)
- n8n (routing logic)
- Directus (business-specific collections)
- Claude API (contextual responses)

## Future Considerations

- Machine learning-based classification
- Customer profile-based routing (returning customer history)
- Multi-language support for keyword detection
