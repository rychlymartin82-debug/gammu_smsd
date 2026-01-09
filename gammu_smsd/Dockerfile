FROM alpine:3.18

RUN apk add --no-cache \
    gammu \
    gammu-smsd \
    jq \
    mosquitto-clients \
    bash

COPY run.sh /usr/local/bin/run.sh
COPY mqtt_bridge.sh /usr/local/bin/mqtt_bridge.sh

RUN chmod +x /usr/local/bin/run.sh && \
    chmod +x /usr/local/bin/mqtt_bridge.sh

CMD ["/usr/local/bin/run.sh"]

