FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gammu \
        gammu-smsd \
        mosquitto-clients \
        bash \
        jq \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy scripts
COPY run.sh /usr/local/bin/run.sh
COPY mqtt_bridge.sh /usr/local/bin/mqtt_bridge.sh

# Permissions
RUN chmod +x /usr/local/bin/run.sh && \
    chmod +x /usr/local/bin/mqtt_bridge.sh

# Create data directory
RUN mkdir -p /data

# Default command
CMD ["/usr/local/bin/run.sh"]


