#!/bin/bash
set -e

# set limits
cat <<EOF > /etc/security/limits.d/elasticsearch.conf
elasticsearch   -       nofile      65535
elasticsearch   hard    memlock     unlimited
elasticsearch   soft    memlock     unlimited
elasticsearch   -       nproc       4096
EOF

# set sysctl
cat <<EOF > /etc/sysctl.d/elasticsearch.conf
vm.max_map_count=262144
EOF

# Apply sysctl immediately
sysctl --system
