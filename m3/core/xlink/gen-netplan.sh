#!/bin/bash
set -e

echo "✅ Startingxlinkr netplan generation…"

OUTFILE="/etc/netplan/88-xlink.yaml"

cat > "$OUTFILE" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ens23:
      dhcp4: no

  bridges:
    br-xlink:
      interfaces: [ens23]
      dhcp4: no

EOF

echo "✅ Netplan configuration written to $OUTFILE"
echo "🔄 Applying netplan now..."
chmod 600 "$OUTFILE"
netplan apply
echo "✅ Done. brxlinke ready and persistent."