#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT="$SCRIPT_DIR/xlink.txt"

if [[ ! -f "$INPUT" ]]; then
    echo "❌ Input file '$INPUT' not found!"
    exit 1
fi

echo "🚀 Starting full mesh xlink configuration…"

while read -r CONTAINER VETH_HOST VETH_CONT BRIDGE IP GATEWAY; do
    # Skip empty lines or comments
    [[ -z "$CONTAINER" || "$CONTAINER" =~ ^# ]] && continue

    echo "🔷 Configuring xlink for $CONTAINER → $IP via $GATEWAY"
    PID=$(docker inspect -f '{{.State.Pid}}' "$CONTAINER" 2>/dev/null) || {
        echo "[-] Container $CONTAINER not found or not running"
        continue
    }

    echo "    → PID: $PID"

    # Clean up existing interfaces
    nsenter -t "$PID" -n ip link del "$VETH_CONT" 2>/dev/null || true
    ip link del "$VETH_HOST" 2>/dev/null || true

    # Create veth pair
    ip link add "$VETH_HOST" type veth peer name "${VETH_HOST}-c"
    ip link set "$VETH_HOST" up
    ip link set "$VETH_HOST" master "$BRIDGE"

    # Bring peer up & move it
    ip link set "${VETH_HOST}-c" up
    ip link set "${VETH_HOST}-c" netns "$PID"

    # Configure inside container
    nsenter -t "$PID" -n ip link set "${VETH_HOST}-c" name "$VETH_CONT"
    nsenter -t "$PID" -n ip link set "$VETH_CONT" up
    nsenter -t "$PID" -n ip addr add "$IP" dev "$VETH_CONT"
    nsenter -t "$PID" -n ip route add default via "$GATEWAY" || true

    echo "✅ Xlink for $CONTAINER: $VETH_CONT → $IP"
done < "$INPUT"

echo "🎯 All full mesh xlink interfaces configured successfully."