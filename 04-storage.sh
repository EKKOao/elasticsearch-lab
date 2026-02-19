#!/bin/bash
set -e

# Create VG01
if ! vgs vg01 >/dev/null 2>&1; then
    DISK=$(lsblk -dn -o NAME,SIZE | grep '15G' | awk '{print "/dev/"$1}')
    pvcreate $DISK
    vgcreate vg01 $DISK
fi

# Helper to create LV and Format XFS
create_lv() {
    local size=$1
    local name=$2
    if ! lvs vg01/$name >/dev/null 2>&1; then
        lvcreate -L $size -n $name vg01
        mkfs.xfs /dev/vg01/$name
    fi
}

# Create LVs
create_lv 2G mnt
create_lv 4G data
create_lv 2G home
create_lv 1G logs
create_lv 4G backup

# Mount hierarchy
mount_and_fstab() {
    local lv=$1
    local path=$2

    mkdir -p $path
    if ! grep -q "$path " /proc/mounts; then
        mount /dev/vg01/$lv $path
        echo "/dev/vg01/$lv $path xfs defaults 0 0" >> /etc/fstab
    fi
}

# Mount /mnt
mount_and_fstab mnt "/mnt"

# Create subfolders
mkdir -p /mnt/elasticsearch/data
mkdir -p /mnt/elasticsearch/home
mkdir -p /mnt/elasticsearch/logs
mkdir -p /mnt/elasticsearch/backup

# Mount the sub-volumes
mount_and_fstab data   "/mnt/elasticsearch/data"
mount_and_fstab home   "/mnt/elasticsearch/home"
mount_and_fstab logs   "/mnt/elasticsearch/logs"
mount_and_fstab backup "/mnt/elasticsearch/backup"

# Fix Permissions
chown -R 1122:1122 /mnt/elasticsearch

lsblk
