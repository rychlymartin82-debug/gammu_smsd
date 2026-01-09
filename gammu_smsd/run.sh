#!/usr/bin/with-contenv bashio

CONFIG_PATH=/data/options.json
SMSD_CONFIG=/data/smsd.conf
SMSD_LOG=/data/smsd.log

# Read options
DEVICE=$(bashio::config 'device')
MQTT_HOST=$(bashio::config 'mqtt_host')
MQTT_PORT=$(bashio::config 'mqtt_port')
MQTT_USER=$(bashio::config 'mqtt_user')
MQTT_PASS=$(bashio::config 'mqtt_password')
MQTT_TOPIC=$(bashio::config 'mqtt_topic')

bashio::log.info "Log filename is \"$SMSD_LOG\""
bashio::log.info ""
bashio::log.info "Using device: $DEVICE"
bashio::log.info "MQTT: host=$MQTT_HOST port=$MQTT_PORT user=$MQTT_USER topic=$MQTT_TOPIC"

# Create SMSD config
cat > $SMSD_CONFIG << EOF
[gammu]
device = $DEVICE
connection = at

[smsd]
service = files
logfile = $SMSD_LOG
debuglevel = 1
inboxpath = /data/inbox/
outboxpath = /data/outbox/
sentsmspath = /data/sent/
errorsmspath = /data/error/

RunOnReceive = /app/on_receive.sh

# MQTT Publishing
PhoneID = SMSGateway
User = $MQTT_USER
Password = $MQTT_PASS
Host = $MQTT_HOST:$MQTT_PORT
ClientID = smsd_gateway

[include_numbers]
number1 = *
EOF

# Create directories
mkdir -p /data/{inbox,outbox,sent,error}

bashio::log.info "Waiting for modem to settle..."
sleep 10

# Test modem connection FIRST
bashio::log.info "Testing modem connection..."
gammu --config $SMSD_CONFIG identify 2>&1 | tee /tmp/gammu_test.log

if [ $? -ne 0 ]; then
    bashio::log.error "❌ MODEM CONNECTION FAILED!"
    bashio::log.error "Error details:"
    cat /tmp/gammu_test.log
    exit 1
fi

bashio::log.info "✅ Modem connected successfully"

# Start SMSD with error output
bashio::log.info "Starting gammu-smsd..."
gammu-smsd --config $SMSD_CONFIG --pid /var/run/smsd.pid 2>&1 | while IFS= read -r line; do
    bashio::log.info "SMSD: $line"
done
