#!/bin/bash
# Minecraft Server Start Script
# Security: Validates environment, checks permissions, handles errors

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load environment variables if .env exists
if [ -f .env ]; then
    set -a
    source .env
    set +a
fi

# Default values
SERVER_JAR="${SERVER_JAR:-server.jar}"
MAX_RAM="${MAX_RAM:-2G}"
MIN_RAM="${MIN_RAM:-1G}"
SERVER_PORT="${SERVER_PORT:-25565}"

# Validation
if [ ! -f "$SERVER_JAR" ]; then
    echo "Error: Server JAR file '$SERVER_JAR' not found"
    exit 1
fi

if [ ! -f "eula.txt" ]; then
    echo "Error: eula.txt not found. Please accept EULA first."
    exit 1
fi

# Check if server is already running
if pgrep -f "java.*$SERVER_JAR" > /dev/null; then
    echo "Error: Minecraft server is already running"
    exit 1
fi

# Create necessary directories
mkdir -p logs worlds backups

# Start server
echo "Starting Minecraft server..."
echo "Max RAM: $MAX_RAM, Min RAM: $MIN_RAM"
echo "Port: $SERVER_PORT"

nohup java -Xmx"$MAX_RAM" -Xms"$MIN_RAM" \
    -XX:+UseG1GC \
    -XX:+ParallelRefProcEnabled \
    -XX:MaxGCPauseMillis=200 \
    -XX:+UnlockExperimentalVMOptions \
    -XX:+DisableExplicitGC \
    -XX:+AlwaysPreTouch \
    -XX:G1NewSizePercent=30 \
    -XX:G1MaxNewSizePercent=40 \
    -XX:G1HeapRegionSize=8M \
    -XX:G1ReservePercent=20 \
    -XX:G1HeapWastePercent=5 \
    -XX:G1MixedGCCountTarget=4 \
    -XX:InitiatingHeapOccupancyPercent=15 \
    -XX:G1MixedGCLiveThresholdPercent=90 \
    -XX:G1RSetUpdatingPauseTimePercent=5 \
    -XX:SurvivorRatio=32 \
    -XX:+PerfDisableSharedMem \
    -XX:MaxTenuringThreshold=1 \
    -Dusing.aikars.flags=https://mcflags.emc.gs \
    -Daikars.new.flags=true \
    -jar "$SERVER_JAR" nogui > logs/server.log 2>&1 &

SERVER_PID=$!
echo "$SERVER_PID" > server.pid
echo "Server started with PID: $SERVER_PID"
echo "Logs: tail -f logs/server.log"

