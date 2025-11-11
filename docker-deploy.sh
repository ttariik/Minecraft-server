#!/bin/bash
# Docker Deployment Script
# Security: Validates Docker installation, builds and deploys containerized server

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Validation
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Error: docker-compose is not installed${NC}"
    exit 1
fi

# Check if server.jar exists
if [ ! -f "server.jar" ]; then
    echo -e "${YELLOW}Warning: server.jar not found${NC}"
    echo "Downloading latest Minecraft server JAR..."
    wget https://piston-data.mojang.com/v1/objects/8f3112a104975aeccdf6dfa80eab10517fbe27d8/server.jar -O server.jar || {
        echo -e "${RED}Error: Failed to download server.jar${NC}"
        exit 1
    }
fi

# Create eula.txt if it doesn't exist
if [ ! -f "eula.txt" ]; then
    echo "eula=true" > eula.txt
fi

# Create necessary directories
mkdir -p worlds logs backups

# Copy server.properties if it doesn't exist
if [ ! -f "server.properties" ]; then
    cp server.properties.example server.properties
    echo -e "${YELLOW}Created server.properties from example${NC}"
fi

echo -e "${GREEN}Building Docker image...${NC}"
docker-compose build

echo -e "${GREEN}Starting containers...${NC}"
docker-compose up -d

echo -e "${GREEN}Docker deployment complete!${NC}"
echo ""
echo "Services:"
echo "  - Minecraft Server: localhost:25565"
echo "  - Web Dashboard: http://localhost:8080"
echo ""
echo "Useful commands:"
echo "  docker-compose logs -f          # View logs"
echo "  docker-compose ps               # Check status"
echo "  docker-compose stop             # Stop services"
echo "  docker-compose down             # Stop and remove containers"

