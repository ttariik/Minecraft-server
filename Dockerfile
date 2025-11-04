# Minecraft Server Dockerfile
# Multi-stage build for optimized image size

FROM eclipse-temurin:17-jre-headless as base

# Security: Non-root user
RUN groupadd -r minecraft && useradd -r -g minecraft -u 1000 minecraft

# Set working directory
WORKDIR /minecraft

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy server files
COPY --chown=minecraft:minecraft server.jar /minecraft/server.jar
COPY --chown=minecraft:minecraft server.properties.example /minecraft/server.properties.example
COPY --chown=minecraft:minecraft eula.txt /minecraft/eula.txt
COPY --chown=minecraft:minecraft start.sh /minecraft/start.sh

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
CMD ["/minecraft/start.sh"]

