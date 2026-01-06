#!/bin/bash
# Setup Directus Collections for Netsurf

set -e

DIRECTUS_URL="http://localhost:8055"
EMAIL="admin@netsurf.gy"
PASSWORD="PLOiiYKAAgjMdYsJug2G2ZcX"

# Get auth token
echo "Authenticating with Directus..."
TOKEN=$(curl -s -X POST "$DIRECTUS_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | jq -r '.data.access_token')

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "Failed to authenticate"
  exit 1
fi

echo "Token obtained successfully"

# Function to create collection
create_collection() {
  local name=$1
  local schema=$2

  echo "Creating collection: $name..."
  curl -s -X POST "$DIRECTUS_URL/collections" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$schema" | jq '.data.collection // .errors[0].message'
}

# Function to create field
create_field() {
  local collection=$1
  local field_schema=$2

  curl -s -X POST "$DIRECTUS_URL/fields/$collection" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$field_schema" > /dev/null
}

# 1. Products Collection
echo ""
echo "=== Creating Products Collection ==="
create_collection "products" '{
  "collection": "products",
  "meta": {
    "icon": "shopping_cart",
    "note": "Internet plans and products"
  },
  "schema": {}
}'

# Products fields
create_field "products" '{"field": "name", "type": "string", "meta": {"interface": "input", "required": true}}'
create_field "products" '{"field": "sku", "type": "string", "meta": {"interface": "input"}}'
create_field "products" '{"field": "category", "type": "string", "meta": {"interface": "select-dropdown", "options": {"choices": [{"text": "Residential", "value": "residential"}, {"text": "Business", "value": "business"}, {"text": "Enterprise", "value": "enterprise"}]}}}'
create_field "products" '{"field": "description", "type": "text", "meta": {"interface": "input-multiline"}}'
create_field "products" '{"field": "price", "type": "decimal", "meta": {"interface": "input"}}'
create_field "products" '{"field": "speed_mbps", "type": "integer", "meta": {"interface": "input"}}'
create_field "products" '{"field": "features", "type": "json", "meta": {"interface": "list"}}'
create_field "products" '{"field": "is_active", "type": "boolean", "meta": {"interface": "boolean", "default_value": true}}'
echo "Products collection created with fields"

# 2. FAQ Collection
echo ""
echo "=== Creating FAQ Collection ==="
create_collection "faq" '{
  "collection": "faq",
  "meta": {
    "icon": "help",
    "note": "Frequently asked questions"
  },
  "schema": {}
}'

create_field "faq" '{"field": "question", "type": "string", "meta": {"interface": "input", "required": true}}'
create_field "faq" '{"field": "answer", "type": "text", "meta": {"interface": "input-multiline", "required": true}}'
create_field "faq" '{"field": "category", "type": "string", "meta": {"interface": "select-dropdown", "options": {"choices": [{"text": "Billing", "value": "billing"}, {"text": "Technical", "value": "technical"}, {"text": "Installation", "value": "installation"}, {"text": "General", "value": "general"}]}}}'
create_field "faq" '{"field": "business", "type": "string", "meta": {"interface": "select-dropdown", "options": {"choices": [{"text": "Netsurf Power", "value": "power"}, {"text": "Netsurf Park", "value": "park"}, {"text": "Both", "value": "both"}]}}}'
create_field "faq" '{"field": "sort_order", "type": "integer", "meta": {"interface": "input"}}'
echo "FAQ collection created with fields"

# 3. Canned Responses Collection
echo ""
echo "=== Creating Canned Responses Collection ==="
create_collection "canned_responses" '{
  "collection": "canned_responses",
  "meta": {
    "icon": "quick_reply",
    "note": "Pre-written response templates"
  },
  "schema": {}
}'

create_field "canned_responses" '{"field": "trigger_keywords", "type": "json", "meta": {"interface": "tags", "required": true}}'
create_field "canned_responses" '{"field": "response_template", "type": "text", "meta": {"interface": "input-multiline", "required": true}}'
create_field "canned_responses" '{"field": "category", "type": "string", "meta": {"interface": "select-dropdown", "options": {"choices": [{"text": "Greeting", "value": "greeting"}, {"text": "Billing", "value": "billing"}, {"text": "Support", "value": "support"}, {"text": "Escalation", "value": "escalation"}]}}}'
create_field "canned_responses" '{"field": "is_active", "type": "boolean", "meta": {"interface": "boolean", "default_value": true}}'
echo "Canned Responses collection created with fields"

# 4. Business Hours Collection
echo ""
echo "=== Creating Business Hours Collection ==="
create_collection "business_hours" '{
  "collection": "business_hours",
  "meta": {
    "icon": "schedule",
    "note": "Operating hours for each business"
  },
  "schema": {}
}'

create_field "business_hours" '{"field": "business", "type": "string", "meta": {"interface": "select-dropdown", "options": {"choices": [{"text": "Netsurf Power", "value": "power"}, {"text": "Netsurf Park", "value": "park"}]}, "required": true}}'
create_field "business_hours" '{"field": "day", "type": "string", "meta": {"interface": "select-dropdown", "options": {"choices": [{"text": "Monday", "value": "monday"}, {"text": "Tuesday", "value": "tuesday"}, {"text": "Wednesday", "value": "wednesday"}, {"text": "Thursday", "value": "thursday"}, {"text": "Friday", "value": "friday"}, {"text": "Saturday", "value": "saturday"}, {"text": "Sunday", "value": "sunday"}]}, "required": true}}'
create_field "business_hours" '{"field": "open_time", "type": "time", "meta": {"interface": "datetime"}}'
create_field "business_hours" '{"field": "close_time", "type": "time", "meta": {"interface": "datetime"}}'
create_field "business_hours" '{"field": "is_closed", "type": "boolean", "meta": {"interface": "boolean", "default_value": false}}'
echo "Business Hours collection created with fields"

# 5. Promotions Collection
echo ""
echo "=== Creating Promotions Collection ==="
create_collection "promotions" '{
  "collection": "promotions",
  "meta": {
    "icon": "local_offer",
    "note": "Active promotions and discounts"
  },
  "schema": {}
}'

create_field "promotions" '{"field": "title", "type": "string", "meta": {"interface": "input", "required": true}}'
create_field "promotions" '{"field": "description", "type": "text", "meta": {"interface": "input-multiline"}}'
create_field "promotions" '{"field": "start_date", "type": "date", "meta": {"interface": "datetime"}}'
create_field "promotions" '{"field": "end_date", "type": "date", "meta": {"interface": "datetime"}}'
create_field "promotions" '{"field": "discount_percent", "type": "integer", "meta": {"interface": "input"}}'
create_field "promotions" '{"field": "promo_code", "type": "string", "meta": {"interface": "input"}}'
create_field "promotions" '{"field": "is_active", "type": "boolean", "meta": {"interface": "boolean", "default_value": true}}'
echo "Promotions collection created with fields"

echo ""
echo "=== All Collections Created Successfully ==="
echo ""

# List all collections
echo "Current collections:"
curl -s "$DIRECTUS_URL/collections" \
  -H "Authorization: Bearer $TOKEN" | jq -r '.data[].collection'
