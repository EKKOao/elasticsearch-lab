#!/bin/bash
set -e
echo "--- Renaming Interface enp0s8 to prod ---"

CURRENT_NAME="enp0s8"
NEW_NAME="prod"

# Check if rename is already done
if ip link show "$NEW_NAME" >/dev/null 2>&1; then
    exit 0
fi

# Get the MAC address of the current interface
if [ -d "/sys/class/net/$CURRENT_NAME" ]; then
    MAC=$(cat /sys/class/net/$CURRENT_NAME/address)
else
    exit 1
fi

# Create persistent Systemd Link Rule
cat <<EOF > /etc/systemd/network/10-rename-prod.link
[Match]
MACAddress=$MAC

[Link]
Name=$NEW_NAME
EOF

# Update Netplan Configuration
sed -i "s/$CURRENT_NAME/$NEW_NAME/g" /etc/netplan/*.yaml

# Apply Changes Immediately
# We can safely down this interface because Vagrant uses enp0s3 (NAT) for SSH.
ip link set $CURRENT_NAME down
ip link set $CURRENT_NAME name $NEW_NAME
ip link set $NEW_NAME up

# Apply Netplan to bind the IP to the new name
netplan apply

#ip addr show $NEW_NAME
