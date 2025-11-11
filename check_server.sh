#!/bin/bash
echo "=== Server Environment Check ==="
echo "Java Version:"
java -version 2>&1 | head -3
echo ""
echo "Disk Space:"
df -h / | tail -1
echo ""
echo "Memory:"
free -h 2>/dev/null || vm_stat | head -5
echo ""
echo "Open Ports:"
netstat -tuln 2>/dev/null | grep LISTEN | grep -E "(25565|22)" || ss -tuln 2>/dev/null | grep LISTEN | grep -E "(25565|22)" || echo "Port check unavailable"
