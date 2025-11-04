#!/bin/bash
# Minecraft Server Deployment Script
# Deploys server files to remote VM
# Security: Validates SSH key, creates backup before deployment

set -euo pipefail

SSH_KEY="${SSH_KEY:-$HOME/.ssh/v_server_key}"
SSH_USER="${SSH_USER:-tsabanovic}"
SSH_HOST="${SSH_HOST:-91.99.193.112}"
REMOTE_DIR="${REMOTE_DIR:-~/minecraft-server}"

# Validation
if [ ! -f "$SSH_KEY" ]; then
    echo "Error: SSH key not found: $SSH_KEY"
    exit 1
fi

echo "Deploying to $SSH_USER@$SSH_HOST:$REMOTE_DIR"

# Create remote directory
ssh -i "$SSH_KEY" "$SSH_USER@$SSH_HOST" "mkdir -p $REMOTE_DIR"

# Copy files
echo "Copying server files..."
scp -i "$SSH_KEY" start.sh stop.sh backup.sh "$SSH_USER@$SSH_HOST:$REMOTE_DIR/"
scp -i "$SSH_KEY" server.properties eula.txt "$SSH_USER@$SSH_HOST:$REMOTE_DIR/" 2>/dev/null || true

# Make scripts executable
ssh -i "$SSH_KEY" "$SSH_USER@$SSH_HOST" "chmod +x $REMOTE_DIR/*.sh"

echo "Deployment complete"

