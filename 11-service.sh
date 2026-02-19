#!/bin/bash
set -e

# Variables
SERVICE_FILE="/etc/systemd/system/elasticsearch.service"
ES_HOME="/mnt/elasticsearch/home"
ES_CONF="$ES_HOME/config"
USER="elasticsearch"
GROUP="elasticsearch"

# Create the Systemd Unit File

cat <<EOF > $SERVICE_FILE
[Unit]
Description=Elasticsearch
Documentation=https://www.elastic.co
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
RuntimeDirectory=elasticsearch
PrivateTmp=true

# Environment Variables
Environment=ES_HOME=$ES_HOME
Environment=ES_PATH_CONF=$ES_CONF
Environment=PID_DIR=/run/elasticsearch

# Execution
WorkingDirectory=$ES_HOME
User=$USER
Group=$GROUP
ExecStart=$ES_HOME/bin/elasticsearch -p /run/elasticsearch/elasticsearch.pid --quiet

# Logging
StandardOutput=journal
StandardError=inherit

# Resource Limits
LimitNOFILE=65535
LimitNPROC=4096
LimitAS=infinity
LimitFSIZE=infinity
LimitMEMLOCK=infinity

# Timeouts
TimeoutStartSec=75
TimeoutStopSec=0
KillSignal=SIGTERM
KillMode=process
SendSIGKILL=no
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
EOF

# Set Kernel Parameters
SYSCTL_FILE="/etc/sysctl.d/99-elasticsearch.conf"
if [ ! -f "$SYSCTL_FILE" ]; then
    echo "vm.max_map_count=262144" > "$SYSCTL_FILE"
    sysctl -p "$SYSCTL_FILE"
fi

# Reload Systemd and Enable
systemctl daemon-reload
systemctl enable elasticsearch

# Check Status
systemctl status elasticsearch --no-pager | grep "Loaded:"
