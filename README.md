# Minecraft Server Project

## Description

Self-hosted Minecraft server with automated deployment, monitoring, and management interface.

## Table of Contents

1. [Description](#description)
2. [Quickstart](#quickstart)
3. [Installation](#installation)
4. [Environment Setup](#environment-setup)
5. [Usage](#usage)
6. [Configuration](#configuration)
7. [Security Guidelines](#security-guidelines)
8. [Backup and Recovery](#backup-and-recovery)
9. [Monitoring](#monitoring)
10. [License](#license)
11. [Contact](#contact)

## Description

Self-hosted Minecraft server with automated deployment, monitoring, and management interface. This project provides a containerized Minecraft server solution with Docker, including a web dashboard for monitoring and management.

Key features:
- Docker-based deployment with docker-compose
- Automated health checks and container restart
- Volume persistence for worlds, logs, and backups
- Web dashboard for server monitoring
- Security hardening (non-root user, dropped capabilities)
- Backup and restore functionality

## Quickstart

### Prerequisites
- Docker and Docker Compose installed
- Minimum 2GB RAM available
- Ports 25565 (Minecraft) and 8888 (Web Dashboard) available

### Quick Start Steps

1. **Clone the repository:**
```bash
git clone https://github.com/ttariik/Minecraft-server.git
cd Minecraft-server
```

2. **Deploy with Docker:**
```bash
chmod +x docker-deploy.sh
./docker-deploy.sh
```

3. **Access the server:**
- Minecraft Server: Connect to `YOUR_SERVER_IP:25565`
- Web Dashboard: Open `http://YOUR_SERVER_IP:8888` in browser

The server will start automatically and persist all data (worlds, logs, backups) in local directories.

## Installation

### Prerequisites

- Ubuntu 22.04 LTS or compatible Linux distribution
- Java 17 or higher (for bare-metal installation)
- Docker and Docker Compose (for containerized deployment)
- Minimum 2GB RAM
- Minimum 10GB free disk space
- Port 25565 (TCP) available

### Docker Deployment (Recommended)

```bash
# Clone repository
git clone https://github.com/ttariik/Minecraft-server.git
cd Minecraft-server

# Make deploy script executable
chmod +x docker-deploy.sh

# Deploy with Docker
./docker-deploy.sh

# Or manually with docker-compose
docker-compose up -d
```

Docker deployment includes:
- Minecraft server container
- Web dashboard (nginx)
- Automatic health checks
- Volume persistence for worlds, logs, backups
- Security hardening (non-root user, dropped capabilities)

### Bare-Metal Server Setup

```bash
# Install Java 17
sudo apt update
sudo apt install -y openjdk-17-jdk-headless

# Create server directory
mkdir -p ~/minecraft-server
cd ~/minecraft-server

# Download Minecraft server JAR
wget https://piston-data.mojang.com/v1/objects/8f3112a104975aeccdf6dfa80eab10517fbe27d8/server.jar -O server.jar

# Accept EULA
echo "eula=true" > eula.txt

# Create directories
mkdir -p logs backups worlds
```

## Environment Setup

Copy `.env.example` to `.env` and configure variables:

```bash
cp .env.example .env
nano .env
```

Required environment variables:
- `SERVER_IP`: Server IP address
- `SERVER_PORT`: Minecraft server port (default: 25565)
- `MAX_RAM`: Maximum RAM allocation (default: 2G)
- `MIN_RAM`: Minimum RAM allocation (default: 1G)

## Usage

### Docker Deployment

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f mc-server

# Stop services
docker-compose stop

# Stop and remove containers
docker-compose down

# Restart services
docker-compose restart

# Access web dashboard
# Open http://YOUR_SERVER_IP:8888 in browser
```

### Bare-Metal Deployment

```bash
# Start Server
./start.sh

# Stop Server
./stop.sh

# View Logs
tail -f logs/latest.log
```

### Access Web Interface

Open `http://YOUR_SERVER_IP:8888` in browser.

## Configuration

### Server Properties

Edit `server.properties` to configure:
- Server name
- Max players
- Difficulty
- Game mode
- Whitelist
- And more

### Firewall Configuration

```bash
# Allow Minecraft port
sudo ufw allow 25565/tcp

# Allow web interface port
sudo ufw allow 8888/tcp
```

## Security Guidelines

1. **Firewall**: Configure UFW or iptables to restrict access
2. **SSH Keys**: Use SSH key authentication, disable password login
3. **Whitelist**: Enable whitelist in server.properties
4. **Backup Encryption**: Encrypt backup files containing sensitive data
5. **Regular Updates**: Keep server JAR and system packages updated
6. **Monitor Access**: Review logs regularly for suspicious activity

## Backup and Recovery

### Automated Backups

Backups run daily at 03:00 UTC via cron:

```bash
# View backup schedule
crontab -l | grep backup

# Manual backup
./backup.sh
```

### Restore Backup

```bash
./restore.sh backups/backup-YYYY-MM-DD.tar.gz
```

## Monitoring

### Server Status

Access web dashboard at `http://YOUR_SERVER_IP:8888` to view:
- Server status
- Player count
- CPU/Memory usage
- Recent logs

### API Endpoint

```bash
curl http://YOUR_SERVER_IP:8888/api/status
```

## License

MIT License

## Contact

Project Repository: https://github.com/ttariik/Minecraft-server

