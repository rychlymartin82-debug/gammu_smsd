#!/bin/bash

# MQTT configuration (loaded from environment or defaults)
MQTT_HOST="${MQTT_HOST:-core-mosquitto}"
MQTT_PORT="${MQTT_PORT:-1883}"
MQTT_USER="${MQTT_USER:-smsd}"
MQTT_PASS="${MQTT_PASS:-EmA605285285}"
MQTT_OUTGOING_TOPIC="${MQTT_OUTGOING_TOPIC:-Ourplace/SMS/Outgoing}"

echo "MQTT bridge starting..."
echo "HOST=$MQTT_HOST PORT=$MQTT_PORT USER=$MQTT_USER TOPIC=$MQTT_OUTGOING_TOPIC"
logger -t gammu_smsd "MQTT bridge starting (host=$MQTT_HOST, topic=$MQTT_OUTGOING_TOPIC)"

# Wait for smsd.log to exist
while [ ! -f /data/smsd.log ]; do
    echo "Waiting for /data/smsd.log..."
    logger -t gammu_smsd "Waiting for /data/smsd.log..."
    sleep 1
done

echo "/data/smsd.log found, starting tail..."
logger -t gammu_smsd "/data/smsd.log found, starting tail"

# Read log and publish messages
tail -F /data/smsd.log | while read -r line; do
    clean_line=$(echo "$line" | xargs)

    if [ -n "$clean_line" ]; then
        echo "Publishing SMS: $clean_line"
        logger -t gammu_smsd "Publishing SMS: $clean_line"

        # Retry MQTT publish until successful
        until mosquitto_pub \
            -h "$MQTT_HOST" \
            -p "$MQTT_PORT" \
            -u "$MQTT_USER" \
            -P "$MQTT_PASS" \
            -t "$MQTT_OUTGOING_TOPIC" \
            -m "$clean_line"; do

            echo "MQTT publish failed, retrying..."
            logger -t gammu_smsd "MQTT publish failed, retrying..."
            sleep 1
        done
    fi
done

