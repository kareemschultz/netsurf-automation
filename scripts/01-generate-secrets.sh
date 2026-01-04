#!/bin/bash
# =============================================================================
# Netsurf Stack - Generate Secrets
# =============================================================================
# Creates strong random passwords and keys for all services
# Outputs to .env file from .env.example template
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_DIR/docker"

echo "=============================================="
echo "Netsurf Stack - Generate Secrets"
echo "=============================================="

# Check for .env.example
if [ ! -f "$DOCKER_DIR/.env.example" ]; then
    echo "ERROR: $DOCKER_DIR/.env.example not found"
    exit 1
fi

# Check if .env already exists
if [ -f "$DOCKER_DIR/.env" ]; then
    echo "WARNING: .env already exists!"
    read -p "Overwrite? (y/N): " CONFIRM
    if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
        echo "Aborted."
        exit 0
    fi
    cp "$DOCKER_DIR/.env" "$DOCKER_DIR/.env.backup.$(date +%Y%m%d%H%M%S)"
    echo "Backup created: .env.backup.*"
fi

# Generate secrets
echo ""
echo "Generating secrets..."

generate_password() {
    openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 24
}

generate_hex() {
    openssl rand -hex "$1"
}

# Generate all required secrets
POSTGRES_PASSWORD=$(generate_password)
N8N_BASIC_AUTH_PASSWORD=$(generate_password)
N8N_ENCRYPTION_KEY=$(generate_hex 16)
DIRECTUS_KEY=$(generate_hex 16)
DIRECTUS_SECRET=$(generate_hex 16)
DIRECTUS_ADMIN_PASSWORD=$(generate_password)
SECRET_KEY_BASE=$(generate_hex 32)

echo "  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:0:8}..."
echo "  N8N_BASIC_AUTH_PASSWORD: ${N8N_BASIC_AUTH_PASSWORD:0:8}..."
echo "  N8N_ENCRYPTION_KEY: ${N8N_ENCRYPTION_KEY:0:8}..."
echo "  DIRECTUS_KEY: ${DIRECTUS_KEY:0:8}..."
echo "  DIRECTUS_SECRET: ${DIRECTUS_SECRET:0:8}..."
echo "  DIRECTUS_ADMIN_PASSWORD: ${DIRECTUS_ADMIN_PASSWORD:0:8}..."
echo "  SECRET_KEY_BASE: ${SECRET_KEY_BASE:0:8}..."

# Create .env from template
cp "$DOCKER_DIR/.env.example" "$DOCKER_DIR/.env"

# Replace placeholders with generated values
sed -i "s/POSTGRES_PASSWORD=CHANGEME_GENERATE_STRONG_PASSWORD/POSTGRES_PASSWORD=$POSTGRES_PASSWORD/" "$DOCKER_DIR/.env"
sed -i "s/N8N_BASIC_AUTH_PASSWORD=CHANGEME_GENERATE_STRONG_PASSWORD/N8N_BASIC_AUTH_PASSWORD=$N8N_BASIC_AUTH_PASSWORD/" "$DOCKER_DIR/.env"
sed -i "s/N8N_ENCRYPTION_KEY=CHANGEME_GENERATE_32_CHAR_HEX/N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY/" "$DOCKER_DIR/.env"
sed -i "s/DIRECTUS_KEY=CHANGEME_GENERATE_32_CHAR_HEX/DIRECTUS_KEY=$DIRECTUS_KEY/" "$DOCKER_DIR/.env"
sed -i "s/DIRECTUS_SECRET=CHANGEME_GENERATE_32_CHAR_HEX/DIRECTUS_SECRET=$DIRECTUS_SECRET/" "$DOCKER_DIR/.env"
sed -i "s/DIRECTUS_ADMIN_PASSWORD=CHANGEME_GENERATE_STRONG_PASSWORD/DIRECTUS_ADMIN_PASSWORD=$DIRECTUS_ADMIN_PASSWORD/" "$DOCKER_DIR/.env"
sed -i "s/SECRET_KEY_BASE=CHANGEME_GENERATE_64_CHAR_HEX/SECRET_KEY_BASE=$SECRET_KEY_BASE/" "$DOCKER_DIR/.env"

echo ""
echo "=============================================="
echo "✓ Secrets generated and saved to:"
echo "  $DOCKER_DIR/.env"
echo ""
echo "IMPORTANT: Save these credentials securely!"
echo ""
echo "Login Credentials:"
echo "  n8n:"
echo "    User: admin"
echo "    Pass: $N8N_BASIC_AUTH_PASSWORD"
echo ""
echo "  Directus:"
echo "    Email: admin@netsurf.gy"
echo "    Pass: $DIRECTUS_ADMIN_PASSWORD"
echo ""
echo "  Chatwoot:"
echo "    Create account on first visit"
echo "=============================================="
