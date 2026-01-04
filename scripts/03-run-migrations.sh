#!/bin/bash
# =============================================================================
# Netsurf Stack - Run Migrations
# =============================================================================
# Runs database migrations for Chatwoot
# Directus auto-migrates on startup
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_DIR/docker"

echo "=============================================="
echo "Netsurf Stack - Running Migrations"
echo "=============================================="

cd "$DOCKER_DIR"

# -----------------------------------------------------------------------------
# Wait for services to be ready
# -----------------------------------------------------------------------------
echo "Checking service readiness..."

# Check PostgreSQL
echo -n "  PostgreSQL: "
if docker compose exec -T postgres pg_isready -U netsurf &>/dev/null; then
    echo "ready ✓"
else
    echo "not ready ✗"
    echo "Wait for PostgreSQL to start and try again"
    exit 1
fi

# Check Chatwoot container is running
echo -n "  Chatwoot container: "
if docker compose ps chatwoot-rails | grep -q "Up"; then
    echo "running ✓"
else
    echo "not running ✗"
    exit 1
fi

# -----------------------------------------------------------------------------
# Chatwoot Migrations
# -----------------------------------------------------------------------------
echo ""
echo "Running Chatwoot migrations..."
echo "(This may take a few minutes on first run)"
echo ""

# The critical command!
docker compose exec -T chatwoot-rails bundle exec rails db:chatwoot_prepare

echo ""
echo "✓ Chatwoot migrations complete"

# -----------------------------------------------------------------------------
# Verify databases
# -----------------------------------------------------------------------------
echo ""
echo "Verifying databases..."

echo -n "  n8n database: "
N8N_TABLES=$(docker compose exec -T postgres psql -U netsurf -d n8n -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
if [ -n "$N8N_TABLES" ] && [ "$N8N_TABLES" -gt 0 ]; then
    echo "$N8N_TABLES tables ✓"
else
    echo "empty (will populate on first use)"
fi

echo -n "  Directus database: "
DIRECTUS_TABLES=$(docker compose exec -T postgres psql -U netsurf -d directus -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
if [ -n "$DIRECTUS_TABLES" ] && [ "$DIRECTUS_TABLES" -gt 0 ]; then
    echo "$DIRECTUS_TABLES tables ✓"
else
    echo "migrating..."
fi

echo -n "  Chatwoot database: "
CHATWOOT_TABLES=$(docker compose exec -T postgres psql -U netsurf -d chatwoot -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' ')
if [ -n "$CHATWOOT_TABLES" ] && [ "$CHATWOOT_TABLES" -gt 0 ]; then
    echo "$CHATWOOT_TABLES tables ✓"
else
    echo "error - migrations may have failed"
    exit 1
fi

# -----------------------------------------------------------------------------
# Restart Chatwoot to pick up schema
# -----------------------------------------------------------------------------
echo ""
echo "Restarting Chatwoot services..."
docker compose restart chatwoot-rails chatwoot-sidekiq

# Wait a moment for restart
sleep 10

echo ""
echo "=============================================="
echo "✓ Migrations complete!"
echo ""
echo "Next step: Verify health"
echo "  ./scripts/04-health-check.sh"
echo "=============================================="
