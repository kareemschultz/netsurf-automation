#!/bin/bash
# Setup Chatwoot Teams for department routing

set -e

# Load environment variables from .env if it exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/../config/docker/.env"

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

# Configuration - use environment variables
CHATWOOT_URL="${CHATWOOT_URL:-http://localhost:3000}"
ACCOUNT_ID="${CHATWOOT_ACCOUNT_ID:-1}"

# Never hardcode API tokens - require from environment
if [ -z "$CHATWOOT_API_TOKEN" ]; then
  echo "CHATWOOT_API_TOKEN not set in environment"
  echo "Please set it via: export CHATWOOT_API_TOKEN='your-token'"
  echo "Get your token from Chatwoot: Profile Settings → Access Token"
  exit 1
fi
API_TOKEN="$CHATWOOT_API_TOKEN"

echo "Setting up Chatwoot teams..."

# Function to create team
create_team() {
  local name=$1
  local description=$2
  local allow_auto=$3

  echo "Creating team: $name..."
  RESULT=$(curl -s -X POST "$CHATWOOT_URL/api/v1/accounts/$ACCOUNT_ID/teams" \
    -H "api_access_token: $API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"name\": \"$name\",
      \"description\": \"$description\",
      \"allow_auto_assign\": $allow_auto
    }")

  TEAM_ID=$(echo "$RESULT" | jq -r '.id // empty')
  if [ -n "$TEAM_ID" ]; then
    echo "  Created team ID: $TEAM_ID"
  else
    ERROR=$(echo "$RESULT" | jq -r '.message // .errors // "Unknown error"')
    echo "  Error: $ERROR"
  fi
}

# Create teams
echo ""
echo "=== Creating Department Teams ==="

create_team "Sales Team" "Handles sales inquiries, new customer signups, and plan upgrades" true
create_team "Support Team" "Technical support, troubleshooting, and service issues" true
create_team "Billing Team" "Payment inquiries, invoice questions, and account changes" true
create_team "Supervisors" "Management oversight - has access to all conversations" false

echo ""
echo "=== Teams Created ==="
echo ""

# List all teams
echo "Current teams:"
curl -s "$CHATWOOT_URL/api/v1/accounts/$ACCOUNT_ID/teams" \
  -H "api_access_token: $API_TOKEN" | jq -r '.[] | "  - \(.name) (ID: \(.id))"'

echo ""
echo "Next steps:"
echo "  1. Add agents to teams via Chatwoot UI: Settings → Teams"
echo "  2. Create inboxes and assign teams to them"
echo "  3. Configure auto-assignment rules per inbox"
