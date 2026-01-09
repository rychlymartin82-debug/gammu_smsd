#!/bin/sh

SMS_FILE="$1"

if [ ! -f "$SMS_FILE" ]; then
  echo "No SMS file provided"
  exit 1
fi

MESSAGE=$(cat "$SMS_FILE")

OPTIONS_FILE="/data/options.json"

[ -z "$MQTT_HOST" ] && MQTT_HOST=$(jq -r '.mqtt_host' "$OPTIONS_FILE")
[ -z "$MQTT_PORT" ] && MQTT_PORT=$(jq -r '.mqtt_port' "$OPTIONS_FILE")
[ -z "$MQTT_USER" ] && MQTT_USER=$(jq -r '.mqtt_user' "$OPTIONS_FILE")
[ -z "$MQTT_PASS" ] && MQTT_PASS=$(jq -r '.mqtt_pass' "$OPTIONS_FILE")
[ -z "$MQTT_TOPIC_OUT" ] && MQTT_TOPIC_OUT=$(jq -r '.mqtt_outgoing_topic' "$OPTIONS_FILE")

mosquitto_pub \
  -h "$MQTT_HOST" \
  -p "$MQTT_PORT" \
  -u "$MQTT_USER" \
  -P "$MQTT_PASS" \
  -t "$MQTT_TOPIC_OUT" \
  -m "$MESSAGE"
