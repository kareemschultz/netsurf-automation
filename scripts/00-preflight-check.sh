#!/bin/bash
# =============================================================================
# Netsurf Stack - Preflight Check
# =============================================================================
# Verifies the VPS is ready for deployment
# Run before any other deployment steps
# =============================================================================

set -e

echo "=============================================="
echo "Netsurf Stack - Preflight Check"
echo "=============================================="

ERRORS=0

# -----------------------------------------------------------------------------
# Check Docker
# -----------------------------------------------------------------------------
echo -n "Checking Docker... "
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
    echo "OK (v$DOCKER_VERSION)"
else
    echo "MISSING"
    echo "  Install: curl -fsSL https://get.docker.com | sh"
    ERRORS=$((ERRORS + 1))
fi

# -----------------------------------------------------------------------------
# Check Docker Compose
# -----------------------------------------------------------------------------
echo -n "Checking Docker Compose... "
if docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version --short)
    echo "OK (v$COMPOSE_VERSION)"
else
    echo "MISSING"
    echo "  Docker Compose V2 is required"
    ERRORS=$((ERRORS + 1))
fi

# -----------------------------------------------------------------------------
# Check Docker is running
# -----------------------------------------------------------------------------
echo -n "Checking Docker daemon... "
if docker info &> /dev/null; then
    echo "OK"
else
    echo "NOT RUNNING"
    echo "  Start with: sudo systemctl start docker"
    ERRORS=$((ERRORS + 1))
fi

# -----------------------------------------------------------------------------
# Check disk space (need at least 10GB free)
# -----------------------------------------------------------------------------
echo -n "Checking disk space... "
FREE_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | tr -d 'G')
if [ "$FREE_SPACE" -ge 10 ]; then
    echo "OK (${FREE_SPACE}GB free)"
else
    echo "LOW (${FREE_SPACE}GB free, need 10GB+)"
    ERRORS=$((ERRORS + 1))
fi

# -----------------------------------------------------------------------------
# Check RAM (recommend at least 4GB)
# -----------------------------------------------------------------------------
echo -n "Checking RAM... "
TOTAL_RAM=$(free -g | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -ge 4 ]; then
    echo "OK (${TOTAL_RAM}GB)"
elif [ "$TOTAL_RAM" -ge 2 ]; then
    echo "WARNING (${TOTAL_RAM}GB - 4GB+ recommended)"
else
    echo "LOW (${TOTAL_RAM}GB - need 4GB+)"
    ERRORS=$((ERRORS + 1))
fi

# -----------------------------------------------------------------------------
# Check required ports
# -----------------------------------------------------------------------------
echo "Checking ports..."
for PORT in 80 443 5678 8055 3000; do
    echo -n "  Port $PORT... "
    if ! ss -tuln | grep -q ":$PORT "; then
        echo "AVAILABLE"
    else
        echo "IN USE"
        echo "    Check with: sudo lsof -i :$PORT"
        if [ "$PORT" -eq 80 ] || [ "$PORT" -eq 443 ]; then
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# -----------------------------------------------------------------------------
# Check required commands
# -----------------------------------------------------------------------------
echo "Checking required tools..."
for CMD in curl wget openssl; do
    echo -n "  $CMD... "
    if command -v $CMD &> /dev/null; then
        echo "OK"
    else
        echo "MISSING (install with: apt install $CMD)"
    fi
done

# -----------------------------------------------------------------------------
# Check DNS (if domains configured)
# -----------------------------------------------------------------------------
if [ -f ".env" ]; then
    source .env
    if [ -n "$N8N_DOMAIN" ]; then
        echo "Checking DNS resolution..."
        for DOMAIN in "$N8N_DOMAIN" "$DIRECTUS_DOMAIN" "$CHATWOOT_DOMAIN"; do
            if [ -n "$DOMAIN" ]; then
                echo -n "  $DOMAIN... "
                if host "$DOMAIN" &> /dev/null; then
                    IP=$(host "$DOMAIN" | awk '/has address/ {print $4}' | head -1)
                    echo "OK ($IP)"
                else
                    echo "NOT RESOLVING"
                    echo "    Configure DNS A record pointing to this server"
                fi
            fi
        done
    fi
fi

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "=============================================="
if [ $ERRORS -eq 0 ]; then
    echo "✓ All checks passed! Ready for deployment."
    echo "=============================================="
    exit 0
else
    echo "✗ $ERRORS error(s) found. Fix before proceeding."
    echo "=============================================="
    exit 1
fi
