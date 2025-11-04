# Minecraft Server Dockerfile
# Multi-stage build for optimized image size

FROM eclipse-temurin:17-jre-jammy

# Security: Non-root user
RUN groupadd -r minecraft && useradd -r -g minecraft -u 1000 minecraft

# Set working directory
WORKDIR /minecraft

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Copy server files
COPY --chown=minecraft:minecraft server.jar /minecraft/server.jar
COPY --chown=minecraft:minecraft server.properties.example /minecraft/server.properties.example
COPY --chown=minecraft:minecraft eula.txt /minecraft/eula.txt
COPY --chown=minecraft:minecraft start.sh /minecraft/start.sh

# Create start script for Docker (foreground process)
RUN echo '#!/bin/bash\n\
set -euo pipefail\n\
cd /minecraft\n\
SERVER_JAR="${SERVER_JAR:-server.jar}"\n\
MAX_RAM="${MAX_RAM:-2G}"\n\
MIN_RAM="${MIN_RAM:-1G}"\n\
mkdir -p logs worlds backups\n\
exec java -Xmx"$MAX_RAM" -Xms"$MIN_RAM" \\\n\
    -XX:+UseG1GC \\\n\
    -XX:+ParallelRefProcEnabled \\\n\
    -XX:MaxGCPauseMillis=200 \\\n\
    -XX:+UnlockExperimentalVMOptions \\\n\
    -XX:+DisableExplicitGC \\\n\
    -XX:+AlwaysPreTouch \\\n\
    -XX:G1NewSizePercent=30 \\\n\
    -XX:G1MaxNewSizePercent=40 \\\n\
    -XX:G1HeapRegionSize=8M \\\n\
    -XX:G1ReservePercent=20 \\\n\
    -XX:G1HeapWastePercent=5 \\\n\
    -XX:G1MixedGCCountTarget=4 \\\n\
    -XX:InitiatingHeapOccupancyPercent=15 \\\n\
    -XX:G1MixedGCLiveThresholdPercent=90 \\\n\
    -XX:G1RSetUpdatingPauseTimePercent=5 \\\n\
    -XX:SurvivorRatio=32 \\\n\
    -XX:+PerfDisableSharedMem \\\n\
    -XX:MaxTenuringThreshold=1 \\\n\
    -Dusing.aikars.flags=https://mcflags.emc.gs \\\n\
    -Daikars.new.flags=true \\\n\
    -jar "$SERVER_JAR" nogui' > /minecraft/docker-start.sh && \
    chmod +x /minecraft/docker-start.sh && \
    chown minecraft:minecraft /minecraft/docker-start.sh

# Create directories
RUN mkdir -p /minecraft/{worlds,logs,backups} && \
    chown -R minecraft:minecraft /minecraft

# Switch to non-root user
USER minecraft

# Expose ports
EXPOSE 25565 25575

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD pgrep -f java || exit 1

# Default command
CMD ["/minecraft/docker-start.sh"]

