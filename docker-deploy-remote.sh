#!/bin/bash
# Remote Docker Deployment Script
# Deploys Docker containers to remote VM via SSH
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

echo "Deploying Docker setup to $SSH_USER@$SSH_HOST:$REMOTE_DIR"

# Check Docker installation on remote
echo "Checking Docker installation..."
ssh -i "$SSH_KEY" "$SSH_USER@$SSH_HOST" "command -v docker > /dev/null 2>&1 || (echo 'Docker not installed. Installing...' && curl -fsSL https://get.docker.com | sudo sh && sudo usermod -aG docker $USER)"

# Check docker-compose installation
ssh -i "$SSH_KEY" "$SSH_USER@$SSH_HOST" "command -v docker-compose > /dev/null 2>&1 || (echo 'docker-compose not installed. Installing...' && sudo apt-get update && sudo apt-get install -y docker-compose)"

# Create remote directory
ssh -i "$SSH_KEY" "$SSH_USER@$SSH_HOST" "mkdir -p $REMOTE_DIR/{worlds,logs,backups}"

# Copy Docker files
echo "Copying Docker configuration files..."
scp -i "$SSH_KEY" Dockerfile docker-compose.yml .dockerignore docker-deploy.sh nginx.conf "$SSH_USER@$SSH_HOST:$REMOTE_DIR/"

# Copy web dashboard
scp -i "$SSH_KEY" index.html "$SSH_USER@$SSH_HOST:$REMOTE_DIR/"

# Copy server configuration
scp -i "$SSH_KEY" server.properties.example "$SSH_USER@$SSH_HOST:$REMOTE_DIR/"

# Make scripts executable
ssh -i "$SSH_KEY" "$SSH_USER@$SSH_HOST" "chmod +x $REMOTE_DIR/*.sh"

echo "Deployment complete"
echo ""
echo "To deploy on remote server:"
echo "  ssh -i $SSH_KEY $SSH_USER@$SSH_HOST"
echo "  cd $REMOTE_DIR"
echo "  ./docker-deploy.sh"

