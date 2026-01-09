#!/bin/bash
set -euo pipefail

OPTIONS_FILE="/data/options.json"

# --- Add-on options (z HA UI) ---
DEVICE=$(jq -r '.device // "/dev/serial/by-id/usb-HUAWEI_HUAWEI_Mobile-if00-port0"' "$OPTIONS_FILE")
PIN=$(jq -r '.pin // ""' "$OPTIONS_FILE")
SMSC=$(jq -r '.smsc // ""' "$OPTIONS_FILE")
LOG_LEVEL=$(jq -r '.log_level // "info"' "$OPTIONS_FILE")
CHECK_INTERVAL=$(jq -r '.check_interval // 10' "$OPTIONS_FILE")
RECEIVE=$(jq -r '.receive // true' "$OPTIONS_FILE")
DELETE_AFTER_RECV=$(jq -r '.delete_after_recv // false' "$OPTIONS_FILE")

MQTT_HOST=$(jq -r '.mqtt_host // "core-mosquitto"' "$OPTIONS_FILE")
MQTT_PORT=$(jq -r '.mqtt_port // 1883' "$OPTIONS_FILE")
MQTT_USER=$(jq -r '.mqtt_user // ""' "$OPTIONS_FILE")
MQTT_PASS=$(jq -r '.mqtt_pass // ""' "$OPTIONS_FILE")
MQTT_TOPIC_OUT=$(jq -r '.mqtt_outgoing_topic // "Ourplace/SMS/Outgoing"' "$OPTIONS_FILE")

echo "Gammu SMSD starting..."
echo "Device: $DEVICE, PIN: ${PIN:+(set)}, Log: $LOG_LEVEL, Interval: $CHECK_INTERVAL"
echo "MQTT: host=$MQTT_HOST port=$MQTT_PORT topic=$MQTT_TOPIC_OUT user=${MQTT_USER:+(set)}"
mkdir -p /data/inbox /data/outbox /data/sent /data/error
touch /data/smsd.log

# --- /etc/gammurc ---
cat >/etc/gammurc <<EOF
[gammu]
device = ${DEVICE}
connection = at
EOF

# --- /etc/gammu-smsdrc ---
cat >/etc/gammu-smsdrc <<EOF
[gammu]
device = ${DEVICE}
connection = at

[smsd]
service = files
logfile = /data/smsd.log
debuglevel = ${LOG_LEVEL}
checkinterval = ${CHECK_INTERVAL}

inboxpath = /data/inbox
outboxpath = /data/outbox
sentpath  = /data/sent
errorpath = /data/error

${PIN:+init = AT+CPIN=${PIN}}
${SMSC:+smsc = ${SMSC}}
receive = ${RECEIVE}
deleteafterreceive = ${DELETE_AFTER_RECV}
EOF

# --- Start SMSD na pozadí ---
gammu-smsd --config /etc/gammu-smsdrc &

# --- MQTT subscriber: očekává JSON {"target":"+420...","message":"Text"} ---
echo "Starting MQTT bridge..."
AUTH_ARGS=()
[[ -n "$MQTT_USER" ]] && AUTH_ARGS+=( -u "$MQTT_USER" )
[[ -n "$MQTT_PASS" ]] && AUTH_ARGS+=( -P "$MQTT_PASS" )

# mosquitto_sub automaticky reconnectuje; běží v popředí a drží život kontejneru
mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" -t "$MQTT_TOPIC_OUT" "${AUTH_ARGS[@]}" \
| while read -r line; do
    # Bezpečný parse JSONu; ignoruj nevalidní vstupy
    TARGET=$(echo "$line" | jq -r '.target // empty' 2>/dev/null || true)
    MESSAGE=$(echo "$line" | jq -r '.message // empty' 2>/dev/null || true)

    if [[ -n "${TARGET:-}" && -n "${MESSAGE:-}" ]]; then
        echo "Injecting SMS from MQTT → target=${TARGET}"
        gammu-smsd-inject TEXT "$TARGET" -text "$MESSAGE" \
          && echo "Queued to outbox" \
          || echo "Inject failed"
    else
        echo "MQTT message ignored (missing target/message): $line"
    fi
done
``
