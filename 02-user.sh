#!/bin/bash
set -e

# Create Group
if ! getent group elasticsearch >/dev/null; then
    groupadd -g 1122 -r elasticsearch
fi

# Create User
if ! id -u elasticsearch >/dev/null 2>&1; then
    useradd -u 1122 -g 1122 -r -s /bin/bash -m -d /home/elasticsearch elasticsearch
fi
