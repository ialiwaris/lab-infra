# 🌐 ISP Core & Metro Lab — BGP MPLS Simulation

## 📖 Overview

This lab simulates a multi-region ISP core and metro network topology using:

* Ubuntu 24.04 hosts (`isp-core` and `isp-metro`)
* Docker containers running FRR (Free Range Routing)
* Linux bridges & VLANs
* iBGP peering and route reflection (planned)

The topology mimics real-world ISP practices with separate core and metro nodes, VLAN-tagged uplinks/downlinks, persistent configuration, and automated verification.

---

## 🏗️ Current Topology

* **Core host (`isp-core`)**

  * Provides regional core routers: `ksa_core`, `uae_core`, `pak_core`, `usa_core`
  * Each core has 3 VLAN-tagged downlinks to metro

* **Metro host (`isp-metro`)**

  * Provides metro routers per region: `ksa_jed`, `ksa_dmm`, `ksa_ruh`, `uae_auh`, `uae_shj`, `uae_fjr`, `pak_lhr`, `pak_khi`, `pak_isb`, `usa_ny`, `usa_dc`, `usa_ca`
  * Each metro container peers with its respective core over a dedicated /30 link

---

## 🧩 Components

✅ **Bridges & VLANs**

* Netplan defines persistent bridges: `br-ksa`, `br-uae`, `br-pak`, `br-usa`
* VLAN interfaces for each downlink (`vlan-ksa-jed`, …) configured on core

✅ **Docker Containers**

* All routers are FRR containers with unique IPs and ASNs

✅ **BGP**

* Core & metro run iBGP (same AS within each region)
* Core advertises default route (`default-originate`)
* Metro installs default route and pings via core

✅ **Persistence**

* Netplan files survive reboots
* `systemd` service (`core-network.service`) calls `/usr/local/bin/core-network-setup.sh`

  * Recreates uplinks & downlinks
  * Restores iptables rules inside containers

✅ **Verification**

* Scripts in `verify/` check ping, BGP neighbor state, and summarize results in a table.

---

## 📂 Directory Structure

```
core/
  uplink/
    uplink.sh
    uplink.txt
  downlink/
    downlink.sh
    downlink.txt
  verify/
    verify_core_bgp.sh
  systemd/
    core-network.service
  /usr/local/bin/core-network-setup.sh

metro/
  uplink/
    uplink.sh
    uplink.txt
  verify/
    verify_metro_bgp.sh
  systemd/
    metro-network.service
  /usr/local/bin/metro-network-setup.sh
```

---

## 🔍 How to Use

### On Core:

✅ Run:

```bash
systemctl restart core-network.service
./core/verify/verify_core_bgp.sh
```

### On Metro:

✅ Run:

```bash
systemctl restart metro-network.service
./metro/verify/verify_metro_bgp.sh
```

Both commands reconfigure bridges, veths, VLANs, iptables, and verify functionality.

---

## 🚀 Next Steps



# 📋 ISP Core & Metro Lab Enhancements

## 🌐 Inter-Core Enhancements

* [ ] **Establish eBGP Peering Between Core Routers Across Regions**

  * Configure cross-links (xlinks) between each regional core router for external BGP peering.
  * Assign /30 or /31 subnets dedicated for inter-core links.
  * Document the ASN topology clearly for eBGP sessions.

* [ ] **Designate KSA and USA Core Routers as Route Reflectors**

  * Configure KSA and USA as Route Reflectors (RR) to simplify iBGP full-mesh.
  * Ensure RR clients are properly configured in other regions.

* [ ] **Test Inter-Regional Routing**

  * Verify proper route advertisement and propagation between regions.
  * Confirm reachability across regions through the core mesh.

* [ ] **Implement Inter-Regional Backhaul Redundancy**

  * Add secondary (backup) links to each core that provide failover connectivity to other regions in case of local internet loss.
  * Test failover scenarios and convergence time.

---

## 🧪 Metro Enhancements

* [ ] **Deploy Customer (LAB) Sites Under Each Metro**

  * Provision one or more customer (LAB) containers under each metro node.
  * Assign dedicated VLANs and subnets per customer site.

* [ ] **Implement MPLS Within Each Region**

  * Configure MPLS LDP (or SR, Segment Routing) across metro routers within the same region to support customer (LAB) transport.
  * Enable MPLS transport between metro nodes and core in the same region.
  * Verify MPLS labels and LSPs are operational.

* [ ] **Verify Customer End-to-End Connectivity**

  * Ensure each customer site can communicate as expected through the metro and core networks.
  * Validate isolation between customers if needed (VRFs).

---

## 🔧 Operational Best Practices

* [ ] **Update Documentation**

  * Add diagrams of updated topology including inter-core xlinks, RRs, and customer sites.
  * Document IP addressing, ASNs, and VLAN/MPLS labels.

* [ ] **Version Control & Backup**

  * Commit all scripts, configs, and documentation to the Git repository.
  * Tag this milestone as `v2.0-pre` once inter-core and customer labs are implemented.

* [ ] **Automation & Health Checks**

  * Extend verification scripts to include MPLS, inter-core routes, and customer reachability.
  * Optionally add periodic cron jobs to re-verify the setup automatically.

---
