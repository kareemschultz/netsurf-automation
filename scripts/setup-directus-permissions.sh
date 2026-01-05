#!/bin/bash
# Configure Directus permissions for public API access

set -e

DIRECTUS_URL="http://localhost:8055"
EMAIL="admin@netsurf.gy"
PASSWORD="PLOiiYKAAgjMdYsJug2G2ZcX"

# Get auth token
TOKEN=$(curl -s -X POST "$DIRECTUS_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | jq -r '.data.access_token')

echo "Configuring public read permissions..."

# Get the public role ID (null role = public)
# In Directus, permissions with role: null apply to unauthenticated requests

# Collections that should be publicly readable
COLLECTIONS=("products" "faq" "canned_responses" "business_hours" "promotions")

for collection in "${COLLECTIONS[@]}"; do
  echo "  Setting read permission for: $collection"

  # Create public read permission
  curl -s -X POST "$DIRECTUS_URL/permissions" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"role\": null,
      \"collection\": \"$collection\",
      \"action\": \"read\",
      \"fields\": [\"*\"]
    }" > /dev/null
done

echo ""
echo "=== Permissions Configured ==="
echo ""
echo "Testing public access..."

# Test public access (no auth token)
for collection in "${COLLECTIONS[@]}"; do
  count=$(curl -s "$DIRECTUS_URL/items/$collection" | jq '.data | length')
  echo "  $collection: $count items accessible publicly"
done

echo ""
echo "Public API endpoints:"
echo "  Products:    $DIRECTUS_URL/items/products"
echo "  FAQ:         $DIRECTUS_URL/items/faq"
echo "  Canned:      $DIRECTUS_URL/items/canned_responses"
echo "  Hours:       $DIRECTUS_URL/items/business_hours"
echo "  Promotions:  $DIRECTUS_URL/items/promotions"
