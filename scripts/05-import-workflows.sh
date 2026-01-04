#!/bin/bash
# =============================================================================
# Netsurf Stack - Import n8n Workflows
# =============================================================================
# Imports pre-built workflows into n8n via API
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_DIR/docker"
WORKFLOWS_DIR="$PROJECT_DIR/n8n-workflows"

echo "=============================================="
echo "Netsurf Stack - Import n8n Workflows"
echo "=============================================="

# Load credentials from .env
cd "$DOCKER_DIR"
source .env

N8N_URL="http://localhost:5678"
N8N_USER="${N8N_BASIC_AUTH_USER:-admin}"
N8N_PASS="${N8N_BASIC_AUTH_PASSWORD}"

if [ -z "$N8N_PASS" ]; then
    echo "ERROR: N8N_BASIC_AUTH_PASSWORD not found in .env"
    exit 1
fi

# Wait for n8n to be ready
echo "Checking n8n availability..."
MAX_WAIT=60
WAIT=0
while [ $WAIT -lt $MAX_WAIT ]; do
    if curl -s -u "$N8N_USER:$N8N_PASS" "$N8N_URL/api/v1/workflows" &>/dev/null; then
        echo "✓ n8n is ready"
        break
    fi
    sleep 5
    WAIT=$((WAIT + 5))
    echo "  Waiting... ($WAIT seconds)"
done

if [ $WAIT -ge $MAX_WAIT ]; then
    echo "ERROR: n8n not responding after $MAX_WAIT seconds"
    exit 1
fi

# Import workflows
echo ""
echo "Importing workflows..."

import_workflow() {
    local FILE=$1
    local NAME=$(basename "$FILE" .json)
    
    echo -n "  $NAME: "
    
    if [ ! -f "$FILE" ]; then
        echo "file not found"
        return 1
    fi
    
    # Import via API
    RESPONSE=$(curl -s -X POST \
        -u "$N8N_USER:$N8N_PASS" \
        -H "Content-Type: application/json" \
        -d @"$FILE" \
        "$N8N_URL/api/v1/workflows" 2>/dev/null)
    
    # Check for success
    if echo "$RESPONSE" | grep -q '"id"'; then
        WORKFLOW_ID=$(echo "$RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "imported (ID: $WORKFLOW_ID)"
        
        # Activate workflow
        curl -s -X PATCH \
            -u "$N8N_USER:$N8N_PASS" \
            -H "Content-Type: application/json" \
            -d '{"active": true}' \
            "$N8N_URL/api/v1/workflows/$WORKFLOW_ID" &>/dev/null
        
        return 0
    else
        ERROR=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
        if [ -n "$ERROR" ]; then
            echo "failed: $ERROR"
        else
            echo "failed (unknown error)"
        fi
        return 1
    fi
}

# Import each workflow
IMPORTED=0
FAILED=0

for WORKFLOW_FILE in "$WORKFLOWS_DIR"/*.json; do
    if [ -f "$WORKFLOW_FILE" ]; then
        if import_workflow "$WORKFLOW_FILE"; then
            IMPORTED=$((IMPORTED + 1))
        else
            FAILED=$((FAILED + 1))
        fi
    fi
done

# List all workflows
echo ""
echo "Current workflows in n8n:"
curl -s -u "$N8N_USER:$N8N_PASS" "$N8N_URL/api/v1/workflows" | \
    python3 -c "import sys,json; data=json.load(sys.stdin); print('  ' + '\n  '.join([f\"{w['name']} (ID: {w['id']}, Active: {w['active']})\" for w in data.get('data', [])]))" 2>/dev/null || \
    echo "  (Could not parse response)"

echo ""
echo "=============================================="
echo "Imported: $IMPORTED workflows"
if [ $FAILED -gt 0 ]; then
    echo "Failed: $FAILED workflows"
fi
echo ""
echo "Next steps:"
echo "1. Login to n8n: http://localhost:5678"
echo "2. Configure credentials (Anthropic, Directus, Chatwoot)"
echo "3. Update workflow nodes to use credentials"
echo "4. Test workflows manually"
echo "=============================================="
