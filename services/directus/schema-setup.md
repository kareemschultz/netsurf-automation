# Netsurf - Directus Schema Setup

This document describes the collections (tables) to create in Directus for Netsurf's automation system.

## How to Create Collections in Directus

1. Login to Directus Admin: `https://cms.netsurf.gy` (or `http://localhost:8055`)
2. Go to **Settings** → **Data Model**
3. Click **"Create Collection"** for each table below
4. Add fields as specified

---

## Collection 1: `internet_plans`

**Purpose:** Store all Netsurf internet service plans

### Fields

| Field Name | Type | Interface | Options |
|------------|------|-----------|---------|
| `id` | UUID | (auto) | Primary Key |
| `name` | String | Input | Required |
| `speed_mbps` | Integer | Input | Required |
| `price` | Decimal | Input | Required |
| `currency` | String | Dropdown | Default: "GYD", Options: GYD, USD |
| `description` | Text | Textarea | |
| `features` | JSON | Tags | Array of feature strings |
| `status` | String | Dropdown | Options: active, inactive, coming_soon |
| `plan_type` | String | Dropdown | Options: residential, business, enterprise |
| `sort` | Integer | Input | For ordering |
| `date_created` | Timestamp | (auto) | |
| `date_updated` | Timestamp | (auto) | |

### Sample Data
```json
{
  "name": "Netsurf Basic",
  "speed_mbps": 10,
  "price": 5000,
  "currency": "GYD",
  "description": "Perfect for browsing and social media",
  "features": ["10 Mbps Download", "5 Mbps Upload", "Unlimited Data", "Free Installation"],
  "status": "active",
  "plan_type": "residential",
  "sort": 1
}
```

---

## Collection 2: `promotions`

**Purpose:** Manage discounts and special offers that AI can reference

### Fields

| Field Name | Type | Interface | Options |
|------------|------|-----------|---------|
| `id` | UUID | (auto) | Primary Key |
| `title` | String | Input | Required |
| `description` | Text | Textarea | Required |
| `discount_percent` | Integer | Slider | Min: 0, Max: 100 |
| `discount_amount` | Decimal | Input | Alternative to percent |
| `target_plan` | M2O | Related (internet_plans) | Optional |
| `promo_code` | String | Input | Optional |
| `start_date` | Date | Datetime | Required |
| `end_date` | Date | Datetime | Required |
| `status` | String | Dropdown | Options: draft, active, expired |
| `auto_post` | Boolean | Toggle | Should social media workflow post this? |
| `image` | File | Image | For social media posts |
| `terms` | Text | WYSIWYG | Fine print |
| `date_created` | Timestamp | (auto) | |

### Sample Data
```json
{
  "title": "New Year Special",
  "description": "Start 2026 with blazing fast internet! Get 50% off your first 3 months.",
  "discount_percent": 50,
  "target_plan": null,
  "start_date": "2026-01-01",
  "end_date": "2026-01-31",
  "status": "active",
  "auto_post": true,
  "terms": "Valid for new residential customers only. Minimum 6-month contract required."
}
```

---

## Collection 3: `faq`

**Purpose:** Knowledge base entries the AI uses to answer questions

### Fields

| Field Name | Type | Interface | Options |
|------------|------|-----------|---------|
| `id` | UUID | (auto) | Primary Key |
| `question` | String | Input | Required |
| `answer` | Text | WYSIWYG | Required |
| `category` | String | Dropdown | Options: billing, technical, plans, general, troubleshooting |
| `keywords` | JSON | Tags | For AI matching |
| `status` | String | Dropdown | Options: published, draft |
| `sort` | Integer | Input | |
| `date_created` | Timestamp | (auto) | |
| `date_updated` | Timestamp | (auto) | |

### Sample Data
```json
{
  "question": "How do I reset my router?",
  "answer": "To reset your Netsurf router:\n1. Locate the reset button (small hole on back)\n2. Use a paperclip to press and hold for 10 seconds\n3. Wait 2-3 minutes for the router to restart\n4. Reconnect to your WiFi network\n\nIf issues persist, contact our support team.",
  "category": "troubleshooting",
  "keywords": ["router", "reset", "restart", "not working", "no internet"],
  "status": "published"
}
```

---

## Collection 4: `business_info`

**Purpose:** General business information the AI references

### Fields

| Field Name | Type | Interface | Options |
|------------|------|-----------|---------|
| `id` | UUID | (auto) | Primary Key |
| `key` | String | Input | Required, Unique |
| `value` | Text | Textarea | Required |
| `description` | String | Input | For staff reference |
| `date_updated` | Timestamp | (auto) | |

### Sample Data
```json
[
  {
    "key": "business_hours",
    "value": "Monday - Friday: 8:00 AM - 5:00 PM\nSaturday: 9:00 AM - 1:00 PM\nSunday: Closed",
    "description": "Office hours for customer support"
  },
  {
    "key": "phone_number",
    "value": "+592 XXX XXXX",
    "description": "Main customer support line"
  },
  {
    "key": "emergency_contact",
    "value": "+592 XXX XXXX (After hours technical emergencies only)",
    "description": "24/7 emergency line"
  },
  {
    "key": "coverage_areas",
    "value": "Georgetown, East Coast Demerara, East Bank Demerara, West Coast Demerara",
    "description": "Service areas"
  },
  {
    "key": "installation_fee",
    "value": "Free installation for all new customers (limited time)",
    "description": "Current installation policy"
  }
]
```

---

## Collection 5: `conversation_logs`

**Purpose:** Log AI conversations for quality review and prompt refinement

### Fields

| Field Name | Type | Interface | Options |
|------------|------|-----------|---------|
| `id` | UUID | (auto) | Primary Key |
| `conversation_id` | Integer | Input | Chatwoot conversation ID |
| `contact_id` | Integer | Input | Chatwoot contact ID |
| `channel` | String | Dropdown | Options: whatsapp, facebook, instagram, webchat |
| `customer_message` | Text | Textarea | What customer said |
| `ai_response` | Text | Textarea | What AI responded |
| `escalated` | Boolean | Toggle | Was this escalated to human? |
| `escalation_reason` | String | Input | Why escalated |
| `feedback` | String | Dropdown | Options: positive, negative, neutral, none |
| `staff_notes` | Text | Textarea | For staff to annotate |
| `timestamp` | Timestamp | Datetime | |

**Note:** This collection is written by n8n, read by staff for QA.

---

## Collection 6: `social_post_logs`

**Purpose:** Track automated social media posts

### Fields

| Field Name | Type | Interface | Options |
|------------|------|-----------|---------|
| `id` | UUID | (auto) | Primary Key |
| `promo_id` | M2O | Related (promotions) | Which promo was posted |
| `promo_title` | String | Input | Denormalized for quick view |
| `facebook_status` | String | Dropdown | Options: posted, failed, skipped |
| `facebook_post_id` | String | Input | Graph API post ID |
| `instagram_status` | String | Dropdown | Options: posted, failed, skipped |
| `instagram_post_id` | String | Input | |
| `tiktok_status` | String | Dropdown | Options: posted, manual_pending, failed, skipped |
| `tiktok_caption` | Text | Textarea | For manual posting |
| `posted_at` | Timestamp | Datetime | |

---

## Roles & Permissions Setup

### Role: "Netsurf Staff"

| Collection | Create | Read | Update | Delete |
|------------|--------|------|--------|--------|
| internet_plans | ✅ | ✅ | ✅ | ❌ |
| promotions | ✅ | ✅ | ✅ | ✅ |
| faq | ✅ | ✅ | ✅ | ✅ |
| business_info | ❌ | ✅ | ✅ | ❌ |
| conversation_logs | ❌ | ✅ | (notes only) | ❌ |
| social_post_logs | ❌ | ✅ | ❌ | ❌ |

### Role: "n8n Service Account"

| Collection | Create | Read | Update | Delete |
|------------|--------|------|--------|--------|
| internet_plans | ❌ | ✅ | ❌ | ❌ |
| promotions | ❌ | ✅ | ❌ | ❌ |
| faq | ❌ | ✅ | ❌ | ❌ |
| business_info | ❌ | ✅ | ❌ | ❌ |
| conversation_logs | ✅ | ✅ | ❌ | ❌ |
| social_post_logs | ✅ | ✅ | ✅ | ❌ |

---

## Creating the n8n API Token

1. In Directus: **Settings** → **Users**
2. Create new user: `n8n-bot@netsurf.gy`
3. Assign role: "n8n Service Account"
4. Go to user → **Generate Static Token**
5. Copy token to your `.env` file as `DIRECTUS_API_TOKEN`

---

## Quick Setup Checklist

- [ ] Create `internet_plans` collection with all fields
- [ ] Create `promotions` collection with all fields  
- [ ] Create `faq` collection with all fields
- [ ] Create `business_info` collection with all fields
- [ ] Create `conversation_logs` collection with all fields
- [ ] Create `social_post_logs` collection with all fields
- [ ] Create "Netsurf Staff" role with permissions
- [ ] Create "n8n Service Account" role with permissions
- [ ] Create staff user accounts
- [ ] Create n8n bot user and generate token
- [ ] Add sample data to each collection
- [ ] Test API endpoints: `GET /items/internet_plans`, etc.
