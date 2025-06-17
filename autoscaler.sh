#!/bin/bash

MAX_VMS=4
MIN_VMS=1
CPU_UP_THRESHOLD=60
CPU_DOWN_THRESHOLD=10
VM_PREFIX="web-vm"

declare -a MAC_LIST=("52:54:00:aa:bb:01" "52:54:00:aa:bb:02" "52:54:00:aa:bb:03" "52:54:00:aa:bb:04")
declare -a IP_LIST=("192.168.122.101" "192.168.122.102" "192.168.122.103" "192.168.122.104")

function get_cpu() {
  local vm_ip="${IP_LIST[0]}"
  # Fetch the CPU percent from the FastAPI metrics endpoint
  curl -s "http://${vm_ip}:8000/metrics" | \
    python3 -c "import sys, json; print(json.load(sys.stdin)['cpu_percent'])"
}

function scale_up() {
  if (( ACTIVE_VMS < MAX_VMS )); then
    echo "[+] Scaling up"
    VM_NAME="$VM_PREFIX$((ALL_VMS + 1))"
    ./create_vm.sh "$VM_NAME" "${MAC_LIST[$ALL_VMS]}" "${IP_LIST[$ALL_VMS]}"
    sleep 5
    sudo ./generate_haproxy_cfg.sh
  fi
}

function scale_down() {
  if (( ACTIVE_VMS > MIN_VMS )); then
    echo "[-] Scaling down"
    VM_NAME="$VM_PREFIX$ALL_VMS"
    ./destroy_vm.sh "$VM_NAME"
    sleep 5
    sudo ./generate_haproxy_cfg.sh
  fi
}

sudo ./generate_haproxy_cfg.sh

while true; do
  ACTIVE_VMS=$(virsh list --state-running | grep "$VM_PREFIX" | wc -l)
  ALL_VMS=$(virsh list --all | grep "$VM_PREFIX" | wc -l)
  if (( ACTIVE_VMS < MIN_VMS )); then
    scale_up
    sleep 80
  fi
  CPU=$(get_cpu)
  echo "CPU usage: $CPU"
  ACTIVE_VMS=$(virsh list --state-running | grep "$VM_PREFIX" | wc -l)
  ALL_VMS=$(virsh list --all | grep "$VM_PREFIX" | wc -l)
  if (( $(echo "$CPU > $CPU_UP_THRESHOLD" | bc -l) )); then
    scale_up
    sleep 80
  elif (( $(echo "$CPU < $CPU_DOWN_THRESHOLD" | bc -l) )); then
    scale_down
    sleep 20
  fi
  sleep 5
done
