#!/bin/bash
# Project Checklist Verification Script
# Verifies all required components for Minecraft Server project

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Minecraft Server Project Checklist Verification ==="
echo ""

ERRORS=0
WARNINGS=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 (MISSING)"
        ((ERRORS++))
        return 1
    fi
}

check_executable() {
    if [ -f "$1" ] && [ -x "$1" ]; then
        echo -e "${GREEN}✓${NC} $1 (executable)"
        return 0
    elif [ -f "$1" ]; then
        echo -e "${YELLOW}⚠${NC} $1 (not executable)"
        ((WARNINGS++))
        return 1
    else
        echo -e "${RED}✗${NC} $1 (MISSING)"
        ((ERRORS++))
        return 1
    fi
}

echo "=== Core Files ==="
check_file "README.md"
check_file "Dockerfile"
check_file "docker-compose.yml"
check_file ".gitignore"
check_file ".dockerignore"
check_file "server.properties.example"
echo ""

echo "=== Deployment Scripts ==="
check_executable "start.sh"
check_executable "stop.sh"
check_executable "backup.sh"
check_executable "deploy.sh"
check_executable "docker-deploy.sh"
check_executable "docker-deploy-remote.sh"
echo ""

echo "=== Configuration Files ==="
check_file "nginx.conf"
check_file "index.html"
echo ""

echo "=== Documentation ==="
if grep -q "Docker" README.md 2>/dev/null; then
    echo -e "${GREEN}✓${NC} README.md contains Docker documentation"
else
    echo -e "${RED}✗${NC} README.md missing Docker documentation"
    ((ERRORS++))
fi

if grep -q "Security" README.md 2>/dev/null; then
    echo -e "${GREEN}✓${NC} README.md contains Security section"
else
    echo -e "${YELLOW}⚠${NC} README.md missing Security section"
    ((WARNINGS++))
fi

if grep -q "Backup" README.md 2>/dev/null; then
    echo -e "${GREEN}✓${NC} README.md contains Backup section"
else
    echo -e "${YELLOW}⚠${NC} README.md missing Backup section"
    ((WARNINGS++))
fi
echo ""

echo "=== Security Checks ==="
if grep -q "non-root" Dockerfile 2>/dev/null || grep -q "USER" Dockerfile 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Dockerfile uses non-root user"
else
    echo -e "${YELLOW}⚠${NC} Dockerfile should use non-root user"
    ((WARNINGS++))
fi

if grep -q "server.properties" .gitignore 2>/dev/null; then
    echo -e "${GREEN}✓${NC} server.properties excluded from git"
else
    echo -e "${YELLOW}⚠${NC} server.properties should be in .gitignore"
    ((WARNINGS++))
fi

if grep -q "eula.txt" .gitignore 2>/dev/null; then
    echo -e "${GREEN}✓${NC} eula.txt excluded from git"
else
    echo -e "${YELLOW}⚠${NC} eula.txt should be in .gitignore"
    ((WARNINGS++))
fi
echo ""

echo "=== Docker Configuration ==="
if grep -q "healthcheck" docker-compose.yml 2>/dev/null || grep -q "healthcheck" Dockerfile 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Health checks configured"
else
    echo -e "${YELLOW}⚠${NC} Health checks recommended"
    ((WARNINGS++))
fi

if grep -q "volumes:" docker-compose.yml 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Volumes configured for persistence"
else
    echo -e "${RED}✗${NC} Volumes not configured"
    ((ERRORS++))
fi

if grep -q "networks:" docker-compose.yml 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Docker network configured"
else
    echo -e "${YELLOW}⚠${NC} Docker network not configured"
    ((WARNINGS++))
fi
echo ""

echo "=== Script Functionality ==="
if grep -q "set -euo pipefail" start.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} start.sh uses proper error handling"
else
    echo -e "${YELLOW}⚠${NC} start.sh should use 'set -euo pipefail'"
    ((WARNINGS++))
fi

if grep -q "pgrep\|pid" stop.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} stop.sh checks for running process"
else
    echo -e "${YELLOW}⚠${NC} stop.sh should verify process before stopping"
    ((WARNINGS++))
fi

if grep -q "tar\|backup" backup.sh 2>/dev/null; then
    echo -e "${GREEN}✓${NC} backup.sh implements backup functionality"
else
    echo -e "${RED}✗${NC} backup.sh missing backup logic"
    ((ERRORS++))
fi
echo ""

echo "=== Web Interface ==="
if grep -q "Minecraft\|Dashboard" index.html 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Web dashboard HTML present"
else
    echo -e "${RED}✗${NC} Web dashboard missing or incomplete"
    ((ERRORS++))
fi

if grep -q "fetch\|api" index.html 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Web dashboard includes API integration"
else
    echo -e "${YELLOW}⚠${NC} Web dashboard may need API integration"
    ((WARNINGS++))
fi
echo ""

echo "=== Summary ==="
echo -e "Errors: ${RED}${ERRORS}${NC}"
echo -e "Warnings: ${YELLOW}${WARNINGS}${NC}"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "\n${GREEN}✓ All checks passed!${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "\n${YELLOW}⚠ Checks passed with warnings${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some checks failed${NC}"
    exit 1
fi

