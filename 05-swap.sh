#!/bin/bash
set -e

# Turn off swap immediately
swapoff -a

# Remove swap entry from /etc/fstab so it stays off after reboot
sed -i '/swap/s/^/#/' /etc/fstab

# Verify
if [ $(swapon --show | wc -l) -eq 0 ]; then
    echo "Swap is disabled."
else
    echo "Swap might still be active."
    swapon --show
fi
