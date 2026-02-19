#!/bin/bash
set -e
echo "--- Configuring Elasticsearch Cluster & JVM ---"

# Variables
ES_HOME="/mnt/elasticsearch/home"
CONFIG_DIR="$ES_HOME/config"
YML_FILE="$CONFIG_DIR/elasticsearch.yml"
JVM_FILE="$CONFIG_DIR/jvm.options.d/heap.options"
HOSTNAME=$(hostname)

# JVM HEAP CONFIGURATION
cat <<EOF > $JVM_FILE
-Xms2g
-Xmx2g
EOF
chown 1122:1122 $JVM_FILE

# ELASTICSEARCH.YML CONFIGURATION

cat <<EOF > $YML_FILE
# --- Cluster & Node ---
cluster.name: es-cluster
node.name: ${HOSTNAME}

# --- Paths ---
path.data: /mnt/elasticsearch/data
path.logs: /mnt/elasticsearch/logs
path.repo: ["/mnt/elasticsearch/backup"]

# --- Network ---
network.host: [_local_, "_prod_"]
http.port: 9200

# --- Discovery ---
discovery.seed_hosts: ["192.168.56.11", "192.168.56.12", "192.168.56.13"]
cluster.initial_master_nodes: ["es1", "es2", "es3"]

# --- Memory ---
bootstrap.memory_lock: true

# --- Safety ---
action.destructive_requires_name: true

# --- Security (xPack) ---
xpack.security.enabled: true

# Transport Layer
xpack.security.transport.ssl.enabled: true
xpack.security.transport.ssl.verification_mode: certificate
xpack.security.transport.ssl.keystore.path: certs/node.p12
xpack.security.transport.ssl.truststore.path: certs/node.p12

# HTTP Layer
xpack.security.http.ssl.enabled: true
xpack.security.http.ssl.keystore.path: certs/node.p12
xpack.security.http.ssl.truststore.path: certs/node.p12
EOF

# Secure the config file
chown 1122:1122 $YML_FILE
chmod 660 $YML_FILE

# RESTART SERVICE

# We perform a reload/restart to apply the changes
systemctl restart elasticsearch

# Wait and Check Health
sleep 15
if systemctl is-active --quiet elasticsearch; then
    PROD_IP=$(ip -4 addr show prod | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
    echo "SUCCESS: Elasticsearch is running on $HOSTNAME binding to prod ($PROD_IP)"
else
    exit 1
fi
