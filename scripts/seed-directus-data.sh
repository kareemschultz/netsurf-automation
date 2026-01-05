#!/bin/bash
# Seed sample data into Directus collections

set -e

DIRECTUS_URL="http://localhost:8055"
EMAIL="admin@netsurf.gy"
PASSWORD="PLOiiYKAAgjMdYsJug2G2ZcX"

# Get auth token
TOKEN=$(curl -s -X POST "$DIRECTUS_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | jq -r '.data.access_token')

echo "Seeding sample data..."

# Function to insert item
insert_item() {
  local collection=$1
  local data=$2
  curl -s -X POST "$DIRECTUS_URL/items/$collection" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$data" > /dev/null
}

# Seed Products (Internet Plans)
echo "Adding products..."
insert_item "products" '{
  "name": "Basic Home",
  "sku": "HOME-25",
  "category": "residential",
  "description": "Perfect for basic browsing and email. Ideal for 1-2 devices.",
  "price": 5000,
  "speed_mbps": 25,
  "features": ["25 Mbps Download", "10 Mbps Upload", "Unlimited Data", "Free Installation"],
  "is_active": true
}'

insert_item "products" '{
  "name": "Family Plus",
  "sku": "HOME-50",
  "category": "residential",
  "description": "Great for streaming and multiple devices. Perfect for families.",
  "price": 8500,
  "speed_mbps": 50,
  "features": ["50 Mbps Download", "25 Mbps Upload", "Unlimited Data", "Free Router", "Free Installation"],
  "is_active": true
}'

insert_item "products" '{
  "name": "Power Home",
  "sku": "HOME-100",
  "category": "residential",
  "description": "Our fastest residential plan. 4K streaming, gaming, work from home.",
  "price": 15000,
  "speed_mbps": 100,
  "features": ["100 Mbps Download", "50 Mbps Upload", "Unlimited Data", "Premium Router", "Priority Support"],
  "is_active": true
}'

insert_item "products" '{
  "name": "Business Starter",
  "sku": "BIZ-50",
  "category": "business",
  "description": "Reliable internet for small businesses. Static IP included.",
  "price": 12000,
  "speed_mbps": 50,
  "features": ["50 Mbps Symmetric", "Static IP", "99.5% Uptime SLA", "Business Support"],
  "is_active": true
}'

insert_item "products" '{
  "name": "Business Pro",
  "sku": "BIZ-100",
  "category": "business",
  "description": "High-performance business internet with dedicated support.",
  "price": 25000,
  "speed_mbps": 100,
  "features": ["100 Mbps Symmetric", "Static IP Block", "99.9% Uptime SLA", "24/7 Support", "Same-Day Repair"],
  "is_active": true
}'
echo "  5 products added"

# Seed FAQ
echo "Adding FAQs..."
insert_item "faq" '{
  "question": "How do I pay my bill?",
  "answer": "You can pay your bill through:\n1. Online Banking Transfer to our account\n2. Mobile Money (pay to Netsurf)\n3. Visit our office at Main Street, Georgetown\n4. Pay at any authorized agent location",
  "category": "billing",
  "business": "both",
  "sort_order": 1
}'

insert_item "faq" '{
  "question": "My internet is slow. What should I do?",
  "answer": "Try these steps:\n1. Restart your router (unplug for 30 seconds)\n2. Check if multiple devices are using the connection\n3. Run a speed test at speedtest.net\n4. Move closer to the router\n\nIf the issue persists, contact support and we will check your connection.",
  "category": "technical",
  "business": "both",
  "sort_order": 2
}'

insert_item "faq" '{
  "question": "How long does installation take?",
  "answer": "Standard installation takes 2-3 business days after payment confirmation. Installation typically takes 1-2 hours depending on your location. Our technician will call you before arriving.",
  "category": "installation",
  "business": "both",
  "sort_order": 3
}'

insert_item "faq" '{
  "question": "What areas do you cover?",
  "answer": "Netsurf provides service in Georgetown, East Coast Demerara, West Coast Demerara, and selected areas in Region 4. Contact us to check availability at your address.",
  "category": "general",
  "business": "both",
  "sort_order": 4
}'

insert_item "faq" '{
  "question": "Can I upgrade my plan?",
  "answer": "Yes! You can upgrade your plan at any time. The new rate will be prorated for the current billing period. Contact us or visit your customer portal to upgrade.",
  "category": "billing",
  "business": "both",
  "sort_order": 5
}'
echo "  5 FAQs added"

# Seed Canned Responses
echo "Adding canned responses..."
insert_item "canned_responses" '{
  "trigger_keywords": ["hello", "hi", "hey", "good morning", "good afternoon"],
  "response_template": "Hello! Welcome to Netsurf. How can I help you today? I can assist with:\n• Billing questions\n• Technical support\n• New service inquiries\n• Plan upgrades\n\nType AGENT anytime to speak with a human representative.",
  "category": "greeting",
  "is_active": true
}'

insert_item "canned_responses" '{
  "trigger_keywords": ["bill", "payment", "pay", "invoice", "amount due"],
  "response_template": "For billing inquiries, I can help you with:\n• Checking your balance\n• Payment methods\n• Due dates\n\nTo check your current balance, please provide your account number or registered phone number.",
  "category": "billing",
  "is_active": true
}'

insert_item "canned_responses" '{
  "trigger_keywords": ["agent", "human", "representative", "speak to someone", "real person"],
  "response_template": "I am connecting you with a customer service representative. Please hold, someone will be with you shortly.\n\nOur support hours are Monday-Friday 8AM-6PM, Saturday 9AM-1PM.",
  "category": "escalation",
  "is_active": true
}'

insert_item "canned_responses" '{
  "trigger_keywords": ["slow", "not working", "down", "no internet", "problem"],
  "response_template": "I am sorry to hear you are experiencing issues. Let me help troubleshoot:\n\n1. Is your router power light on?\n2. Have you tried restarting the router?\n3. Are all devices affected?\n\nPlease describe what you are seeing and I will assist further.",
  "category": "support",
  "is_active": true
}'
echo "  4 canned responses added"

# Seed Business Hours
echo "Adding business hours..."
for day in monday tuesday wednesday thursday friday; do
  insert_item "business_hours" "{
    \"business\": \"power\",
    \"day\": \"$day\",
    \"open_time\": \"08:00:00\",
    \"close_time\": \"17:00:00\",
    \"is_closed\": false
  }"
done

insert_item "business_hours" '{
  "business": "power",
  "day": "saturday",
  "open_time": "09:00:00",
  "close_time": "13:00:00",
  "is_closed": false
}'

insert_item "business_hours" '{
  "business": "power",
  "day": "sunday",
  "open_time": null,
  "close_time": null,
  "is_closed": true
}'
echo "  7 business hours entries added"

# Seed Promotions
echo "Adding promotions..."
insert_item "promotions" '{
  "title": "New Year Special",
  "description": "Sign up in January and get 50% off your first month! Valid for all residential plans.",
  "start_date": "2026-01-01",
  "end_date": "2026-01-31",
  "discount_percent": 50,
  "promo_code": "NEWYEAR26",
  "is_active": true
}'

insert_item "promotions" '{
  "title": "Refer a Friend",
  "description": "Refer a friend and you both get a free month of service when they sign up!",
  "start_date": "2026-01-01",
  "end_date": "2026-12-31",
  "discount_percent": 100,
  "promo_code": "REFER2026",
  "is_active": true
}'
echo "  2 promotions added"

echo ""
echo "=== Sample Data Seeded Successfully ==="

# Show counts
echo ""
echo "Collection counts:"
for collection in products faq canned_responses business_hours promotions; do
  count=$(curl -s "$DIRECTUS_URL/items/$collection?aggregate[count]=*" \
    -H "Authorization: Bearer $TOKEN" | jq -r '.data[0].count')
  echo "  $collection: $count items"
done
