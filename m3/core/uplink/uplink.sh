#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT="$SCRIPT_DIR/uplink.txt"

while read -r CONTAINER VETH_HOST VETH_CONT BRIDGE IP GATEWAY; do
    echo "[*] Configuring uplink for $CONTAINER"
    PID=$(docker inspect -f '{{.State.Pid}}' $CONTAINER 2>/dev/null) || {
        echo "[-] Container $CONTAINER not found or not running"
        continue
    }

    ip link del $VETH_HOST || true
    ip link add $VETH_HOST type veth peer name ${VETH_HOST}-c
    ip link set $VETH_HOST up
    ip link set $VETH_HOST master $BRIDGE
    ip link set ${VETH_HOST}-c netns $PID

    nsenter -t $PID -n ip link set ${VETH_HOST}-c name $VETH_CONT
    nsenter -t $PID -n ip link set $VETH_CONT up
    nsenter -t $PID -n ip addr add $IP dev $VETH_CONT
    nsenter -t $PID -n ip route add default via $GATEWAY || true

    echo "[+] Uplink for $CONTAINER on $VETH_CONT → $IP"
done < "$INPUT"