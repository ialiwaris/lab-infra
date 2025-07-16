#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT="$SCRIPT_DIR/downlink.txt"

while read -r CONTAINER VETH_HOST VETH_CONT VLAN_PARENT VLAN_ID IP; do
    echo "[*] Configuring downlink for $CONTAINER ($VETH_CONT)"

    PID=$(docker inspect -f '{{.State.Pid}}' "$CONTAINER" 2>/dev/null) || {
        echo "[-] Container $CONTAINER not found or not running"
        continue
    }

    # Clean up if exists
    ip link del "$VETH_HOST" 2>/dev/null || true

    # Create veth pair
    ip link add "$VETH_HOST" type veth peer name "${VETH_HOST}-c"
    ip link set "$VETH_HOST" up
    ip link set "$VETH_HOST" master "$VLAN_PARENT"

    # Remove default VLAN 1 and set correct VLAN
    bridge vlan del dev "$VETH_HOST" vid 1 2>/dev/null || true
    bridge vlan add dev "$VETH_HOST" vid "$VLAN_ID" pvid untagged

    # Move container end into container namespace and rename
    ip link set "${VETH_HOST}-c" netns "$PID"
    nsenter -t "$PID" -n ip link set "${VETH_HOST}-c" name "$VETH_CONT"
    nsenter -t "$PID" -n ip link set "$VETH_CONT" up
    nsenter -t "$PID" -n ip addr add "$IP" dev "$VETH_CONT"

    echo "[+] Downlink $VETH_CONT in $CONTAINER → $IP on VLAN $VLAN_ID ($VLAN_PARENT)"
done < "$INPUT"