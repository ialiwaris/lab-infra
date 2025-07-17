#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT="$SCRIPT_DIR/bgp_peers.txt"

if [[ ! -f "$INPUT" ]]; then
    echo "❌ Input file '$INPUT' not found!"
    exit 1
fi

echo "🚀 Starting BGP neighbor configuration…"

while read -r CONTAINER LOCAL_AS NEIGHBOR_IP REMOTE_AS DESC; do
    [[ -z "$CONTAINER" || "$CONTAINER" =~ ^# ]] && continue

    echo "🔷 Configuring $NEIGHBOR_IP on $CONTAINER (ASN $LOCAL_AS) → remote ASN $REMOTE_AS"
    docker exec -i "$CONTAINER" vtysh <<EOF
conf t
router bgp $LOCAL_AS
 neighbor $NEIGHBOR_IP remote-as $REMOTE_AS
 neighbor $NEIGHBOR_IP description $DESC
exit
write memory
EOF

    echo "✅ Neighbor $NEIGHBOR_IP configured on $CONTAINER"
done < "$INPUT"

echo "🎯 All BGP neighbors configured successfully."