#!/bin/bash
# Minecraft Server Stop Script
# Security: Graceful shutdown, validates PID, handles errors

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f "server.pid" ]; then
    echo "Error: server.pid not found. Server may not be running."
    exit 1
fi

SERVER_PID=$(cat server.pid)

if ! ps -p "$SERVER_PID" > /dev/null 2>&1; then
    echo "Error: Process $SERVER_PID not found. Server may have stopped."
    rm -f server.pid
    exit 1
fi

echo "Stopping Minecraft server (PID: $SERVER_PID)..."
echo "stop" > server_fifo

# Wait for graceful shutdown (max 30 seconds)
for i in {1..30}; do
    if ! ps -p "$SERVER_PID" > /dev/null 2>&1; then
        echo "Server stopped gracefully"
        rm -f server.pid server_fifo
        exit 0
    fi
    sleep 1
done

# Force kill if still running
if ps -p "$SERVER_PID" > /dev/null 2>&1; then
    echo "Force killing server..."
    kill -9 "$SERVER_PID"
    rm -f server.pid server_fifo
    echo "Server force stopped"
fi

