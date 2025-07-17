#!/bin/bash
set -e

echo "[*] Running core uplink configuration…"
/root/lab-infra/m3/core/uplink/uplink.sh

echo "[*] Running core downlink configuration…"
/root/lab-infra/m3/core/downlink/downlink.sh

echo "[*] Running core xlink configuration…"
/root/lab-infra/m3/core/xlink/xlink.sh

for c in ksa_core uae_core pak_core usa_core; do
    echo "[*] Restoring iptables rules inside $c"
    docker exec "$c" sh -c 'iptables-restore < /etc/iptables/rules.v4'
done

echo "[+] Core network setup complete."
