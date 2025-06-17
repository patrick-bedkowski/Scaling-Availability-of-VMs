#!/bin/bash

TEMPLATE="haproxy_template.cfg"
OUTPUT="/etc/haproxy/haproxy.cfg"

VM_LIST=$(virsh list --name | grep web-vm)
SERVER_CFG=""

for VM in $VM_LIST; do
  IP=$(virsh domifaddr "$VM" | grep 192.168.122 | awk '{print $4}' | cut -d'/' -f1)
  SERVER_CFG+="    server $VM $IP:8000 check slowstart 80\n"
done

# sed "/#__SERVERS__/c\\$SERVER_CFG" "$TEMPLATE" > "$OUTPUT"

awk -v servers="$SERVER_CFG" '
  /#__SERVERS__/ {
    print servers
    next
  }
  { print }
' "$TEMPLATE" | tee "$OUTPUT"

sudo systemctl restart haproxy
