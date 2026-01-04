#!/bin/bash
# =============================================================================
# Netsurf Stack - Health Check
# =============================================================================
# Verifies all services are responding correctly
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_DIR/docker"

echo "=============================================="
echo "Netsurf Stack - Health Check"
echo "=============================================="

cd "$DOCKER_DIR"

ERRORS=0

# -----------------------------------------------------------------------------
# Container Status
# -----------------------------------------------------------------------------
echo "Container Status:"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Health}}"

# -----------------------------------------------------------------------------
# HTTP Health Checks
# -----------------------------------------------------------------------------
echo ""
echo "HTTP Health Checks:"

check_http() {
    local NAME=$1
    local URL=$2
    local EXPECTED=$3
    
    echo -n "  $NAME ($URL): "
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL" 2>/dev/null || echo "000")
    
    if [ "$HTTP_CODE" = "$EXPECTED" ] || [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "401" ]; then
        echo "OK (HTTP $HTTP_CODE)"
        return 0
    else
        echo "FAILED (HTTP $HTTP_CODE, expected $EXPECTED)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
}

check_http "n8n" "http://localhost:5678/healthz" "200"
check_http "Directus" "http://localhost:8055/server/health" "200"
check_http "Chatwoot" "http://localhost:3000/api" "200"

# -----------------------------------------------------------------------------
# Database Connectivity
# -----------------------------------------------------------------------------
echo ""
echo "Database Connectivity:"

echo -n "  PostgreSQL: "
if docker compose exec -T postgres pg_isready -U netsurf &>/dev/null; then
    echo "OK"
else
    echo "FAILED"
    ERRORS=$((ERRORS + 1))
fi

echo -n "  Redis: "
REDIS_PONG=$(docker compose exec -T redis redis-cli ping 2>/dev/null || echo "")
if [ "$REDIS_PONG" = "PONG" ]; then
    echo "OK"
else
    echo "FAILED"
    ERRORS=$((ERRORS + 1))
fi

# -----------------------------------------------------------------------------
# Database Tables
# -----------------------------------------------------------------------------
echo ""
echo "Database Tables:"

for DB in n8n directus chatwoot; do
    echo -n "  $DB: "
    COUNT=$(docker compose exec -T postgres psql -U netsurf -d "$DB" -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ' || echo "0")
    if [ -n "$COUNT" ] && [ "$COUNT" -gt 0 ]; then
        echo "$COUNT tables"
    else
        echo "empty or error"
        if [ "$DB" = "chatwoot" ]; then
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# -----------------------------------------------------------------------------
# Resource Usage
# -----------------------------------------------------------------------------
echo ""
echo "Resource Usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep netsurf || true

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
    echo "✓ All health checks passed!"
    echo ""
    echo "Access your services:"
    echo "  n8n:      http://localhost:5678"
    echo "  Directus: http://localhost:8055"
    echo "  Chatwoot: http://localhost:3000"
    echo ""
    echo "Next step: Import n8n workflows"
    echo "  ./scripts/05-import-workflows.sh"
else
    echo "✗ $ERRORS health check(s) failed"
    echo ""
    echo "Troubleshooting:"
    echo "  docker compose logs <service>"
fi
echo "=============================================="

exit $ERRORS
