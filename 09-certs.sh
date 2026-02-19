#!/bin/bash
set -e

ES_HOME="/mnt/elasticsearch/home"
CERT_TOOL="$ES_HOME/bin/elasticsearch-certutil"
NFS_PATH="/mnt/elasticsearch/backup" 
LOCAL_CERTS="$ES_HOME/config/certs"
HOSTNAME=$(hostname)

# IP Calc
NODE_NUM=$(echo $HOSTNAME | tr -dc '0-9')
NODE_IP="192.168.56.$((10 + NODE_NUM))"

# --- CA GENERATION (es1 only) ---
if [ "$HOSTNAME" == "es1" ]; then
    if [ ! -f "$NFS_PATH/elastic-stack-ca.p12" ]; then
        $CERT_TOOL ca --out "$NFS_PATH/elastic-stack-ca.p12" --pass ""
    fi
    chmod 777 "$NFS_PATH/elastic-stack-ca.p12"
fi

# --- CERT GENERATION ---
while [ ! -f "$NFS_PATH/elastic-stack-ca.p12" ]; do sleep 2; done

mkdir -p "$LOCAL_CERTS"

# UPDATED NAME: node.p12
if [ ! -f "$LOCAL_CERTS/node.p12" ]; then
    $CERT_TOOL cert \
        --ca "$NFS_PATH/elastic-stack-ca.p12" \
        --ca-pass "" \
        --out "$LOCAL_CERTS/node.p12" \
        --pass "" \
        --name "$HOSTNAME" \
        --dns "$HOSTNAME,localhost" \
        --ip "$NODE_IP,127.0.0.1"
fi

chown -R 1122:1122 "$LOCAL_CERTS"
chmod 600 "$LOCAL_CERTS/node.p12"
chmod 700 "$LOCAL_CERTS"

# --- CLEANUP ---
touch "$NFS_PATH/$HOSTNAME.cert_done"
DONE_COUNT=$(find "$NFS_PATH" -maxdepth 1 -name "*.cert_done" | wc -l)

if [ "$DONE_COUNT" -ge 3 ]; then
    rm -f "$NFS_PATH/elastic-stack-ca.p12"
    rm -f "$NFS_PATH"/*.cert_done
    rm -f "$NFS_PATH"/*.txt
fi
