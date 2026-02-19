#!/bin/bash
set -e
echo "--- Downloading and Installing Elasticsearch ---"

URL="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-9.3.0-linux-x86_64.tar.gz"
TMP_FILE="/tmp/elasticsearch.tar.gz"
DEST_DIR="/mnt/elasticsearch/home"

# Download
wget -q -O "$TMP_FILE" "$URL"

# Extract
tar -xzf "$TMP_FILE" -C "$DEST_DIR" --strip-components=1

# Cleanup
rm -f "$TMP_FILE"

# Permission Fix
chown -R 1122:1122 "$DEST_DIR"

