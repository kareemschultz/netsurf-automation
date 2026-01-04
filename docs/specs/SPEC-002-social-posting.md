# SPEC-002: Social Media Auto-Posting

**Status:** Draft
**Author:** Netsurf Team
**Created:** 2026-01-04
**Last Updated:** 2026-01-04

## Overview

This specification defines the requirements for automated social media content generation and posting across Facebook, Instagram, and TikTok.

## Objectives

1. Automatically generate promotional content using AI
2. Post to Facebook and Instagram via API
3. Prepare TikTok content for manual posting
4. Track all social media activity

## Functional Requirements

### FR-001: Scheduling

- **FR-001.1**: System SHALL run on configured schedule (default: Mon & Thu at 9:00 AM)
- **FR-001.2**: System SHALL support manual trigger for immediate posting
- **FR-001.3**: System SHALL skip execution if no active promotions exist

### FR-002: Promotion Selection

- **FR-002.1**: System SHALL fetch promotions from Directus where:
  - `status` = "active"
  - `end_date` >= current date
  - `auto_post` = true
- **FR-002.2**: System SHALL limit to 3 promotions per execution
- **FR-002.3**: System SHALL prioritize promotions by end date (soonest first)

### FR-003: Content Generation

- **FR-003.1**: System SHALL call Claude API to generate platform-specific content
- **FR-003.2**: Claude SHALL generate:
  - Facebook: Post text (max 500 chars) + hashtags
  - Instagram: Caption (max 300 chars) + hashtags
  - TikTok: Short caption (max 150 chars) + hashtags
- **FR-003.3**: Content SHALL be on-brand (friendly, professional, community-focused)
- **FR-003.4**: Content SHALL include call-to-action

### FR-004: Facebook Posting

- **FR-004.1**: System SHALL post to Facebook Page via Graph API
- **FR-004.2**: System SHALL attach promotion image if available
- **FR-004.3**: System SHALL capture post ID for tracking
- **FR-004.4**: System SHALL handle API errors gracefully

### FR-005: Instagram Posting

- **FR-005.1**: System SHALL create media container via Content Publishing API
- **FR-005.2**: System SHALL publish media container
- **FR-005.3**: System SHALL use default image if promotion has no image
- **FR-005.4**: System SHALL capture media ID for tracking

### FR-006: TikTok Handling

- **FR-006.1**: System SHALL NOT post directly to TikTok (API limitations)
- **FR-006.2**: System SHALL generate TikTok-optimized caption
- **FR-006.3**: System SHALL email caption to staff for manual posting
- **FR-006.4**: System SHALL log with status "manual_pending"

### FR-007: Logging

- **FR-007.1**: System SHALL log all posts to Directus `social_post_logs`
- **FR-007.2**: Log SHALL include: promo_id, platform statuses, post IDs, timestamp
- **FR-007.3**: Failed posts SHALL include error details
- **FR-007.4**: System SHALL send notification on failures

## Non-Functional Requirements

### NFR-001: Reliability

- System SHALL continue posting to remaining platforms if one fails
- System SHALL retry failed API calls up to 3 times

### NFR-002: Security

- API tokens SHALL be stored securely
- System SHALL use minimal API scopes

### NFR-003: Compliance

- Content SHALL comply with platform advertising policies
- System SHALL not post duplicate content within 24 hours

## Data Model

### Input (Directus Promotion)

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string",
  "discount_percent": "number",
  "promo_code": "string",
  "end_date": "date",
  "image": "file",
  "auto_post": "boolean"
}
```

### Output (Claude Generated Content)

```json
{
  "facebook": {
    "text": "string (max 500)",
    "hashtags": "string"
  },
  "instagram": {
    "caption": "string (max 300)",
    "hashtags": "string"
  },
  "tiktok": {
    "caption": "string (max 150)",
    "hashtags": "string"
  }
}
```

### Log Entry

```json
{
  "promo_id": "uuid",
  "promo_title": "string",
  "facebook_status": "posted|failed|skipped",
  "facebook_post_id": "string",
  "instagram_status": "posted|failed|skipped",
  "instagram_post_id": "string",
  "tiktok_status": "manual_pending|failed|skipped",
  "tiktok_caption": "string",
  "posted_at": "timestamp"
}
```

## Acceptance Criteria

- [ ] Scheduled execution works correctly
- [ ] Promotions are fetched with correct filters
- [ ] AI generates platform-appropriate content
- [ ] Facebook posts are published successfully
- [ ] Instagram posts are published successfully
- [ ] TikTok captions are emailed to staff
- [ ] All activity is logged
- [ ] Failures are handled gracefully

## Dependencies

- n8n (workflow orchestration)
- Directus (promotion data, logging)
- Claude API (content generation)
- Facebook Graph API (posting)
- Instagram Content Publishing API (posting)
- SMTP (email notifications)
