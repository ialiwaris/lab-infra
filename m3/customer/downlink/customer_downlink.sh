#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT="$SCRIPT_DIR/customer_downlink.txt"

if [[ ! -f "$INPUT" ]]; then
    echo "Input file '$INPUT' not found!"
    exit 1
fi

while read -r CONTAINER VETH_HOST VETH_CONT IP_CIDR; do
    [[ -z "$CONTAINER" || "$CONTAINER" =~ ^# ]] && continue

    echo "[*] Configuring downlink for $CONTAINER ($VETH_CONT → $IP_CIDR)"

    PID=$(docker inspect -f '{{.State.Pid}}' "$CONTAINER" 2>/dev/null) || {
        echo "[-] Container $CONTAINER not found or not running"
        continue
    }

    # Clean up if exists
    ip link del "$VETH_HOST" 2>/dev/null || true

    # Create veth pair
    ip link add "$VETH_HOST" type veth peer name "${VETH_HOST}-c"
    ip link set "$VETH_HOST" up
    ip link set "$VETH_HOST" master br-cpe

    # Move container side into container namespace
    ip link set "${VETH_HOST}-c" netns "$PID"

    nsenter -t "$PID" -n ip link set "${VETH_HOST}-c" name "$VETH_CONT"
    nsenter -t "$PID" -n ip link set "$VETH_CONT" up
    nsenter -t "$PID" -n ip addr add "$IP_CIDR" dev "$VETH_CONT"

    echo "[+] Configured $VETH_CONT in $CONTAINER with $IP_CIDR"
done < "$INPUT"

echo "✅ All downlinks configured."