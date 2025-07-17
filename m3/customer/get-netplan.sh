#!/bin/bash
set -e

echo "✅ Starting customer netplan generation…"

OUTFILE="/etc/netplan/99-customer.yaml"

cat > "$OUTFILE" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ens23:
      dhcp4: no

  bridges:
    br-cpe:
      interfaces: [ens23]
      dhcp4: no

EOF

echo "✅ Netplan configuration written to $OUTFILE"
echo "🔄 Applying netplan now..."
chmod 600 "$OUTFILE"
netplan apply
echo "✅ Done. br-cpe ready and persistent."
