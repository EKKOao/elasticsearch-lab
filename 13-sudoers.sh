#!/bin/bash
set -e

SUDO_FILE="/etc/sudoers.d/elasticsearch"

# Allow systemctl commands without password
cat <<EOF > $SUDO_FILE
elasticsearch ALL=(root) NOPASSWD: /usr/bin/systemctl start elasticsearch.service
elasticsearch ALL=(root) NOPASSWD: /usr/bin/systemctl stop elasticsearch.service
elasticsearch ALL=(root) NOPASSWD: /usr/bin/systemctl restart elasticsearch.service
elasticsearch ALL=(root) NOPASSWD: /usr/bin/systemctl status elasticsearch.service
elasticsearch ALL=(root) NOPASSWD: /usr/bin/systemctl status elasticsearch
EOF

# Strict permissions are required for sudoers files
chmod 0440 $SUDO_FILE
