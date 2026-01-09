FROM alpine:3.18

# Instalace potřebných balíků
RUN apk add --no-cache \
    gammu \
    gammu-smsd \
    jq \
    mosquitto-clients \
    bash

# Zkopíruj skripty
COPY run.sh /usr/local/bin/run.sh
COPY mqtt_bridge.sh /usr/local/bin/mqtt_bridge.sh

# Nastav práva
RUN chmod +x /usr/local/bin/run.sh && \
    chmod +x /usr/local/bin/mqtt_bridge.sh

# Spouštěcí skript
CMD ["/usr/local/bin/run.sh"]


