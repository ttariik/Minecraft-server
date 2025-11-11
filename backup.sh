#!/bin/bash
# Minecraft Server Backup Script
# Security: Validates paths, creates timestamped backups, handles errors

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BACKUP_DIR="${BACKUP_DIR:-backups}"
WORLD_NAME="${WORLD_NAME:-world}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_${TIMESTAMP}.tar.gz"

# Validation
if [ ! -d "$WORLD_NAME" ]; then
    echo "Error: World directory '$WORLD_NAME' not found"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

# Create backup
echo "Creating backup: $BACKUP_FILE"
tar -czf "$BACKUP_FILE" \
    "$WORLD_NAME" \
    server.properties \
    eula.txt \
    whitelist.json \
    ops.json \
    banned-ips.json \
    banned-players.json \
    2>/dev/null || true

# Verify backup
if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "Backup created successfully: $BACKUP_FILE ($BACKUP_SIZE)"
    
    # Remove backups older than 7 days
    find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
    echo "Old backups cleaned (older than 7 days)"
else
    echo "Error: Backup creation failed"
    exit 1
fi

