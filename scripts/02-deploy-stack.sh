#!/bin/bash
# =============================================================================
# Netsurf Stack - Deploy Stack
# =============================================================================
# Starts all containers and waits for them to be healthy
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_DIR/docker"

echo "=============================================="
echo "Netsurf Stack - Deploying"
echo "=============================================="

# Check .env exists
if [ ! -f "$DOCKER_DIR/.env" ]; then
    echo "ERROR: .env not found!"
    echo "Run ./scripts/01-generate-secrets.sh first"
    exit 1
fi

cd "$DOCKER_DIR"

# Validate .env has required vars
echo "Validating configuration..."
source .env

REQUIRED_VARS=(
    "POSTGRES_PASSWORD"
    "N8N_BASIC_AUTH_PASSWORD"
    "N8N_ENCRYPTION_KEY"
    "DIRECTUS_KEY"
    "DIRECTUS_SECRET"
    "DIRECTUS_ADMIN_PASSWORD"
    "SECRET_KEY_BASE"
)

for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ] || [[ "${!VAR}" == *"CHANGEME"* ]]; then
        echo "ERROR: $VAR is not set or still has placeholder value"
        exit 1
    fi
done
echo "✓ Configuration valid"

# Pull latest images
echo ""
echo "Pulling latest images..."
docker compose pull

# Start the stack
echo ""
echo "Starting containers..."
docker compose up -d

# Wait for health checks
echo ""
echo "Waiting for services to be healthy..."

wait_for_healthy() {
    local SERVICE=$1
    local MAX_WAIT=120
    local WAIT=0
    
    echo -n "  $SERVICE: "
    while [ $WAIT -lt $MAX_WAIT ]; do
        STATUS=$(docker compose ps --format json | jq -r "select(.Name | contains(\"$SERVICE\")) | .Health" 2>/dev/null || echo "unknown")
        
        if [ "$STATUS" = "healthy" ]; then
            echo "healthy ✓"
            return 0
        elif [ "$STATUS" = "unhealthy" ]; then
            echo "unhealthy ✗"
            echo "    Check logs: docker compose logs $SERVICE"
            return 1
        fi
        
        sleep 5
        WAIT=$((WAIT + 5))
        echo -n "."
    done
    
    echo "timeout ✗"
    return 1
}

# Wait for critical services
FAILED=0
for SERVICE in postgres redis n8n directus chatwoot; do
    if ! wait_for_healthy "$SERVICE"; then
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "=============================================="
docker compose ps
echo "=============================================="

if [ $FAILED -gt 0 ]; then
    echo ""
    echo "⚠ $FAILED service(s) may have issues"
    echo "Check logs: docker compose logs <service>"
    exit 1
else
    echo ""
    echo "✓ All services started!"
    echo ""
    echo "Next step: Run migrations"
    echo "  ./scripts/03-run-migrations.sh"
fi
