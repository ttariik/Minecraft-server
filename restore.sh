#!/bin/bash
# Minecraft Server Restore Script
# Security: Validates backup file, creates backup before restore, handles errors

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BACKUP_DIR="${BACKUP_DIR:-backups}"
WORLD_NAME="${WORLD_NAME:-world}"

# Check if backup file provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <backup_file.tar.gz>"
    echo ""
    echo "Available backups:"
    ls -lh "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

# Validation
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file '$BACKUP_FILE' not found"
    exit 1
fi

if ! file "$BACKUP_FILE" | grep -q "gzip\|tar"; then
    echo "Error: '$BACKUP_FILE' does not appear to be a valid tar.gz file"
    exit 1
fi

# Check if server is running
if pgrep -f "java.*server.jar" > /dev/null; then
    echo "Warning: Server is running. Stopping server before restore..."
    echo "stop" > server_fifo 2>/dev/null || ./stop.sh
    sleep 5
fi

# Create backup of current state before restore
echo "Creating backup of current state..."
CURRENT_BACKUP="$BACKUP_DIR/pre_restore_$(date +%Y%m%d_%H%M%S).tar.gz"
mkdir -p "$BACKUP_DIR"
tar -czf "$CURRENT_BACKUP" \
    "$WORLD_NAME" \
    server.properties \
    eula.txt \
    whitelist.json \
    ops.json \
    banned-ips.json \
    banned-players.json \
    2>/dev/null || true
echo "Current state backed up to: $CURRENT_BACKUP"

# Extract backup
echo "Restoring from: $BACKUP_FILE"
tar -xzf "$BACKUP_FILE" -C .

# Verify restore
if [ -d "$WORLD_NAME" ]; then
    echo "Restore completed successfully"
    echo ""
    echo "Next steps:"
    echo "  1. Review restored files"
    echo "  2. Start server: ./start.sh"
    echo "  3. If restore failed, recover from: $CURRENT_BACKUP"
else
    echo "Error: Restore verification failed. World directory not found"
    echo "Recover from: $CURRENT_BACKUP"
    exit 1
fi

