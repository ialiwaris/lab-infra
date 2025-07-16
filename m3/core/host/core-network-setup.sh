# cat /usr/local/bin/core-network-setup.sh
#!/bin/bash
set -e

/root/core/uplink/uplink.sh
/root/core/downlink/downlink.sh

for c in ksa_core uae_core pak_core usa_core; do
    echo "[*] Restoring iptables rules inside $c"
    docker exec "$c" sh -c 'iptables-restore < /etc/iptables/rules.v4'
done

echo "[+] Core network setup complete."