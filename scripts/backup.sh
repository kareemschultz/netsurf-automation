#!/bin/bash
# =============================================================================
# Netsurf Stack - Backup Script
# =============================================================================
# Creates database backups for all services
# Add to crontab: 0 2 * * * /opt/netsurf-stack/scripts/backup.sh
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DOCKER_DIR="$PROJECT_DIR/docker"
BACKUP_DIR="${BACKUP_DIR:-/opt/backups/netsurf}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

DATE=$(date +%Y%m%d_%H%M%S)

echo "=============================================="
echo "Netsurf Stack - Backup"
echo "Date: $(date)"
echo "=============================================="

cd "$DOCKER_DIR"

# -----------------------------------------------------------------------------
# Database Backups
# -----------------------------------------------------------------------------
echo "Backing up databases..."

for DB in n8n directus chatwoot; do
    BACKUP_FILE="$BACKUP_DIR/${DB}_${DATE}.sql.gz"
    echo -n "  $DB: "
    
    if docker compose exec -T postgres pg_dump -U netsurf -d "$DB" | gzip > "$BACKUP_FILE"; then
        SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
        echo "$BACKUP_FILE ($SIZE)"
    else
        echo "FAILED"
        rm -f "$BACKUP_FILE"
    fi
done

# -----------------------------------------------------------------------------
# Volume Backups (optional - commented out as they can be large)
# -----------------------------------------------------------------------------
# echo ""
# echo "Backing up volumes..."
# 
# # Directus uploads
# UPLOADS_BACKUP="$BACKUP_DIR/directus_uploads_${DATE}.tar.gz"
# docker run --rm -v netsurf-directus-uploads:/data -v "$BACKUP_DIR:/backup" alpine \
#     tar czf "/backup/directus_uploads_${DATE}.tar.gz" -C /data .
# echo "  Directus uploads: $UPLOADS_BACKUP"

# -----------------------------------------------------------------------------
# Configuration Backup
# -----------------------------------------------------------------------------
echo ""
echo "Backing up configuration..."
CONFIG_BACKUP="$BACKUP_DIR/config_${DATE}.tar.gz"
tar czf "$CONFIG_BACKUP" \
    -C "$DOCKER_DIR" \
    --exclude='.env' \
    docker-compose.yml Caddyfile init-databases.sql 2>/dev/null || true
echo "  Config: $CONFIG_BACKUP"

# Backup .env separately (contains secrets)
ENV_BACKUP="$BACKUP_DIR/env_${DATE}.enc"
if [ -f "$DOCKER_DIR/.env" ]; then
    # Simple base64 encoding - for production, use proper encryption
    base64 "$DOCKER_DIR/.env" > "$ENV_BACKUP"
    chmod 600 "$ENV_BACKUP"
    echo "  .env: $ENV_BACKUP (encoded)"
fi

# -----------------------------------------------------------------------------
# Cleanup Old Backups
# -----------------------------------------------------------------------------
echo ""
echo "Cleaning up backups older than $RETENTION_DAYS days..."
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "*.enc" -mtime +$RETENTION_DAYS -delete

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo ""
echo "=============================================="
echo "Backup complete!"
echo ""
echo "Backup location: $BACKUP_DIR"
echo "Files:"
ls -lh "$BACKUP_DIR"/*"$DATE"* 2>/dev/null || echo "  No files found"
echo ""
echo "Total backup size:"
du -sh "$BACKUP_DIR"
echo "=============================================="

# -----------------------------------------------------------------------------
# Optional: Offsite sync (uncomment and configure)
# -----------------------------------------------------------------------------
# echo ""
# echo "Syncing to offsite storage..."
# rclone sync "$BACKUP_DIR" remote:netsurf-backups/ --max-age 7d
# echo "✓ Offsite sync complete"
