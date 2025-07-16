#!/bin/bash

set -e

OUTFILE="/etc/netplan/99-bridges.yaml"

cat > "$OUTFILE" <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ens18:
      dhcp4: no
    ens19:
      dhcp4: no
    ens20:
      dhcp4: no
    ens21:
      dhcp4: no
    ens22:
      dhcp4: no

  bridges:
    br-inet:
      interfaces: [ens18]
      dhcp4: no
      addresses: [192.168.10.55/30]
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
        search: [lab.miaj.dev]
      routes:
        - to: default
          via: 192.168.10.1

    br-ksa:
      interfaces: [ens19]
      dhcp4: no

    br-uae:
      interfaces: [ens20]
      dhcp4: no

    br-pak:
      interfaces: [ens21]
      dhcp4: no

    br-usa:
      interfaces: [ens22]
      dhcp4: no

  vlans:
    vlan-ksa-jed:
      id: 11
      link: br-ksa
      dhcp4: no

    vlan-ksa-dmm:
      id: 12
      link: br-ksa
      dhcp4: no

    vlan-ksa-ruh:
      id: 13
      link: br-ksa
      dhcp4: no

    vlan-uae-auh:
      id: 11
      link: br-uae
      dhcp4: no

    vlan-uae-shj:
      id: 12
      link: br-uae
      dhcp4: no

    vlan-uae-fjr:
      id: 13
      link: br-uae
      dhcp4: no

    vlan-pak-lhr:
      id: 11
      link: br-pak
      dhcp4: no

    vlan-pak-khi:
      id: 12
      link: br-pak
      dhcp4: no

    vlan-pak-isb:
      id: 13
      link: br-pak
      dhcp4: no

    vlan-usa-ny:
      id: 11
      link: br-usa
      dhcp4: no

    vlan-usa-dc:
      id: 12
      link: br-usa
      dhcp4: no

    vlan-usa-ca:
      id: 13
      link: br-usa
      dhcp4: no
EOF

echo "✅ Netplan configuration written to $OUTFILE"
echo "🔄 Applying netplan now..."
chmod 600 /etc/netplan/99-bridges.yaml
netplan apply
echo "✅ Done. Bridges + VLANs are ready and persistent."