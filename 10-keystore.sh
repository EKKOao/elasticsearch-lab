#!/bin/bash
set -e
echo "--- Setup Keystore ---"

ES_HOME="/mnt/elasticsearch/home"
KEYSTORE_BIN="$ES_HOME/bin/elasticsearch-keystore"
PASS_FILE="/tmp/keystore_pass"

# Create a temp file with a NEWLINE
echo "" > "$PASS_FILE"

# Create Keystore
if [ ! -f "$ES_HOME/config/elasticsearch.keystore" ]; then
    $KEYSTORE_BIN create
fi

# Add Keys function
add_key() {
    local key_name=$1
    if ! $KEYSTORE_BIN list | grep -q "$key_name"; then
        $KEYSTORE_BIN add --stdin --force "$key_name" < "$PASS_FILE"
    fi
}

# Add Transport Layer Passwords
add_key "xpack.security.transport.ssl.keystore.secure_password"
add_key "xpack.security.transport.ssl.truststore.secure_password"

# Add HTTP Layer Passwords
add_key "xpack.security.http.ssl.keystore.secure_password"
add_key "xpack.security.http.ssl.truststore.secure_password"

# Cleanup & Permissions
rm -f "$PASS_FILE"

chown 1122:1122 "$ES_HOME/config/elasticsearch.keystore"
chmod 600 "$ES_HOME/config/elasticsearch.keystore"

