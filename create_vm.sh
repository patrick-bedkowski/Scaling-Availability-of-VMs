#!/bin/bash

VM_NAME=$1           # np. web-vm1
MAC_ADDR=$2          # np. 52:54:00:aa:bb:01
IP_ADDR=$3
BASE_IMG="/var/lib/libvirt/images/jammy-server-cloudimg-amd64.img"
DISK_SIZE=6          # GB
CLOUD_INIT="./cloud-init.yaml"

virt-install \
  --name "$VM_NAME" \
  --memory 2048 \
  --vcpus 3 \
  --disk size=${DISK_SIZE},backing_store="${BASE_IMG}" \
  --network network=default,mac="$MAC_ADDR" \
  --os-variant ubuntu22.04 \
  --cloud-init user-data="$CLOUD_INIT" \
  --graphics none \
  --noautoconsole

# Add static DHCP mapping
if ! virsh net-dumpxml default | grep -q "$MAC_ADDR"; then
  virsh net-update default add ip-dhcp-host \
  "<host mac='$MAC_ADDR' name='$VM_NAME' ip='$IP_ADDR'/>" \
  --live --config
fi
