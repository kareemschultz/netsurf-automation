#!/bin/bash
# =============================================================================
# Netsurf Stack - Troubleshooting Helper
# =============================================================================
# Collects diagnostic information for troubleshooting
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_DIR/docker"

echo "=============================================="
echo "Netsurf Stack - Troubleshooting Report"
echo "Generated: $(date)"
echo "=============================================="

cd "$DOCKER_DIR"

# -----------------------------------------------------------------------------
# System Info
# -----------------------------------------------------------------------------
echo ""
echo "=== SYSTEM INFO ==="
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"

# -----------------------------------------------------------------------------
# Resources
# -----------------------------------------------------------------------------
echo ""
echo "=== RESOURCES ==="
echo "Memory:"
free -h
echo ""
echo "Disk:"
df -h /
echo ""
echo "CPU Load:"
uptime

# -----------------------------------------------------------------------------
# Docker Status
# -----------------------------------------------------------------------------
echo ""
echo "=== DOCKER STATUS ==="
echo "Docker Version: $(docker --version)"
echo "Compose Version: $(docker compose version --short)"
echo ""
echo "Container Status:"
docker compose ps
echo ""
echo "Container Resources:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}" | grep netsurf || echo "No containers running"

# -----------------------------------------------------------------------------
# Service Health
# -----------------------------------------------------------------------------
echo ""
echo "=== SERVICE HEALTH ==="

check_service() {
    local NAME=$1
    local URL=$2
    echo -n "$NAME: "
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL" 2>/dev/null || echo "000")
    echo "HTTP $HTTP_CODE"
}

check_service "n8n" "http://localhost:5678/healthz"
check_service "Directus" "http://localhost:8055/server/health"
check_service "Chatwoot" "http://localhost:3000/api"

echo ""
echo "Database:"
echo -n "  PostgreSQL: "
docker compose exec -T postgres pg_isready -U netsurf 2>/dev/null && echo "ready" || echo "not ready"
echo -n "  Redis: "
docker compose exec -T redis redis-cli ping 2>/dev/null || echo "not responding"

# -----------------------------------------------------------------------------
# Recent Logs
# -----------------------------------------------------------------------------
echo ""
echo "=== RECENT LOGS (last 20 lines per service) ==="

for SERVICE in postgres redis n8n directus chatwoot-rails; do
    echo ""
    echo "--- $SERVICE ---"
    docker compose logs --tail=20 "$SERVICE" 2>/dev/null || echo "No logs available"
done

# -----------------------------------------------------------------------------
# Network
# -----------------------------------------------------------------------------
echo ""
echo "=== NETWORK ==="
echo "Listening Ports:"
ss -tuln | grep -E ":(80|443|5678|8055|3000|5432|6379) " || echo "No relevant ports listening"
echo ""
echo "Docker Networks:"
docker network ls | grep netsurf

# -----------------------------------------------------------------------------
# Environment Check
# -----------------------------------------------------------------------------
echo ""
echo "=== ENVIRONMENT ==="
if [ -f ".env" ]; then
    echo ".env file exists"
    echo "Variables set (names only):"
    grep -v '^#' .env | grep -v '^$' | cut -d'=' -f1 | sed 's/^/  /'
else
    echo ".env file MISSING"
fi

# -----------------------------------------------------------------------------
# Common Issues
# -----------------------------------------------------------------------------
echo ""
echo "=== COMMON ISSUES CHECK ==="

# Check for OOM kills
echo -n "OOM Kills: "
dmesg 2>/dev/null | grep -i "out of memory" | tail -1 || echo "None detected"

# Check for full disk
echo -n "Disk Space: "
DISK_USE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
if [ "$DISK_USE" -gt 90 ]; then
    echo "CRITICAL ($DISK_USE% used)"
else
    echo "OK ($DISK_USE% used)"
fi

# Check container restarts
echo "Container Restart Counts:"
docker compose ps --format json 2>/dev/null | \
    python3 -c "import sys,json; [print(f\"  {c.get('Name', 'unknown')}: {c.get('State', 'unknown')}\") for c in json.loads('['+','.join(sys.stdin.readlines())+']')]" 2>/dev/null || \
    docker compose ps

echo ""
echo "=============================================="
echo "Troubleshooting Tips:"
echo "1. Check full logs: docker compose logs <service>"
echo "2. Enter container: docker compose exec <service> sh"
echo "3. Restart service: docker compose restart <service>"
echo "4. Full restart: docker compose down && docker compose up -d"
echo "5. Check docs: OFFICIAL-DOCS.md"
echo "=============================================="
