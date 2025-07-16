Here’s a ready-to-drop-in `TROUBLESHOOTING.md` for your repository:

---

# 🧰 Troubleshooting Guide

This guide provides commands and checks to help troubleshoot and validate the nested virtualized lab infrastructure, especially around L2 bridging, VLAN tagging, container networking, and BGP peering.

---

## 📋 Table of Contents

* [Bridges and VLANs](#bridges-and-vlans)
* [Host ↔ Container veth pairs](#host-↔-container-veth-pairs)
* [Container L2 Neighbor State](#container-l2-neighbor-state)
* [Ping & Connectivity](#ping--connectivity)
* [BGP and Routing](#bgp-and-routing)
* [Other Useful Checks](#other-useful-checks)
* [Suggested Workflow](#suggested-workflow)

---

## 🌉 Bridges and VLANs

✅ Show all bridges and attached interfaces:

```bash
brctl show
```

✅ Show VLANs configured on bridges and ports:

```bash
bridge vlan show
```

✅ Check VLAN configuration for just veth interfaces:

```bash
bridge vlan show | grep veth
```

✅ Inspect VLANs and PVID on specific interface:

```bash
bridge vlan show dev <interface>
```

---

## 🔗 Host ↔ Container veth pairs

✅ List all interfaces and see which are UP:

```bash
ip -br a
```

✅ Inspect container namespace PID:

```bash
docker inspect -f '{{.State.Pid}}' <container>
```

✅ Enter container network namespace manually:

```bash
nsenter -t <PID> -n
```

---

## 📶 Container L2 Neighbor State

✅ View container interfaces:

```bash
docker exec <container> ip -br a
```

✅ Check container ARP/NDP neighbor table:

```bash
docker exec <container> ip neigh
```

**Neighbor states:**

* `REACHABLE` — ✅ Good
* `STALE` or `DELAY` — ⚠️ OK but idle
* `INCOMPLETE` — ❌ No L2 resolution

---

## 🛰️ Ping & Connectivity

✅ Ping peer from host:

```bash
ping <IP>
```

✅ Ping peer from container:

```bash
docker exec <container> ping <IP>
```

✅ Ping using specific source IP:

```bash
docker exec <container> ping -I <source-IP> <destination-IP>
```

✅ Ping host default gateway from container:

```bash
ping <host-IP>
```

---

## 📊 BGP and Routing

✅ Show BGP summary in container:

```bash
docker exec <container> vtysh -c "show ip bgp summary"
```

✅ Show routing table in container:

```bash
docker exec <container> vtysh -c "show ip route"
```

---

## 📝 Other Useful Checks

✅ Check if interfaces are up after boot:

```bash
ip link show
```

✅ Verify host IPv4 forwarding is enabled:

```bash
sysctl net.ipv4.ip_forward
```

✅ Reload iptables rules inside container:

```bash
docker exec <container> iptables-restore < /etc/iptables/rules.v4
```

✅ Restart the core-network systemd service:

```bash
systemctl restart core-network.service
systemctl status core-network.service
```

---

## 🧭 Suggested Workflow

✅ On host:

```bash
brctl show
bridge vlan show
ip -br a
```

✅ On container:

```bash
docker exec <container> ip -br a
docker exec <container> ip neigh
docker exec <container> ping <peer-IP>
docker exec <container> vtysh -c "show ip bgp summary"
```

✅ Optional manual fix:

```bash
docker exec <container> iptables-restore < /etc/iptables/rules.v4
```

---

🎯 **Tip:** Always verify bridges and VLAN tagging first before diving into container-level debugging!

---
