#!/bin/bash

echo "Starting MQTT bridge..."

mosquitto_pub \
    -h "${MQTT_HOST}" \
    -p "${MQTT_PORT}" \
    -u "${MQTT_USER}" \
    -P "${MQTT_PASS}" \
    -t "${MQTT_OUTGOING_TOPIC}" \
    -m "SMSD started" || echo "Error: Connection refused"

tail -F /data/smsd.log | while read line; do
    if echo "$line" | grep -q "Received SMS"; then
        mosquitto_pub \
            -h "${MQTT_HOST}" \
            -p "${MQTT_PORT}" \
            -u "${MQTT_USER}" \
            -P "${MQTT_PASS}" \
            -t "${MQTT_OUTGOING_TOPIC}" \
            -m "$line"
    fi
done
