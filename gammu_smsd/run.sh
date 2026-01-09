#!/bin/bash

CONFIG_FILE="/etc/gammu-smsdrc"
DEVICE="${DEVICE:-/dev/ttyUSB2}"

cat <<EOF > $CONFIG_FILE
[gammu]
device = ${DEVICE}
connection = at

[smsd]
service = files
logfile = /data/smsd.log
logformat = text
EOF

mkdir -p /data

echo "Using device: ${DEVICE}"

# Start MQTT bridge
/usr/local/bin/mqtt_bridge.sh &

# Start SMSD
gammu-smsd -c $CONFIG_FILE

wait
