# Minecraft Server Project

## Description

Self-hosted Minecraft server with automated deployment, monitoring, and management interface.

## Table of Contents

1. [Installation](#installation)
2. [Environment Setup](#environment-setup)
3. [Usage](#usage)
4. [Configuration](#configuration)
5. [Security Guidelines](#security-guidelines)
6. [Backup and Recovery](#backup-and-recovery)
7. [Monitoring](#monitoring)
8. [License](#license)
9. [Contact](#contact)

## Installation

### Prerequisites

- Ubuntu 22.04 LTS or compatible Linux distribution
- Java 17 or higher
- Minimum 2GB RAM
- Minimum 10GB free disk space
- Port 25565 (TCP) available

### Server Setup

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

### Start Server

```bash
./start.sh
```

### Stop Server

```bash
./stop.sh
```

### View Logs

```bash
tail -f logs/latest.log
```

### Access Web Interface

Open `http://YOUR_SERVER_IP:8080` in browser.

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
sudo ufw allow 8080/tcp
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

Access web dashboard at `http://YOUR_SERVER_IP:8080` to view:
- Server status
- Player count
- CPU/Memory usage
- Recent logs

### API Endpoint

```bash
curl http://YOUR_SERVER_IP:8080/api/status
```

## License

MIT License

## Contact

Project Repository: https://github.com/ttariik/Minecraft-server

