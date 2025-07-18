# 🧪 Lab Setup: ISP Core & Metro with FRRouting in Docker

> ✅ **Objective:** Clone and configure two VMs (`isp-core`, `isp-metro`) for simulating ISP-level network segments using FRRouting inside Docker containers with bridged and VLAN interfaces.

---

## 🛠️ Step-by-Step Instructions

### 1. 📦 Clone VMs

Clone two VMs named:

* `isp-core`
* `isp-metro`

Start both VMs and log into them.

---

### 2. 🐳 Install Docker on Both VMs

Run on both VMs:

```bash
curl -fsSL https://get.docker.com | sh
```

---

### 3. 📥 Pull FRRouting Docker Image

On both servers:

```bash
docker pull frrouting/frr
```

---

### 4. 🌐 Network Configuration

#### 4.1 Disable `systemd-networkd-wait-online`

```bash
systemctl mask systemd-networkd-wait-online
```

Then power off both VMs.

#### 4.2 Disable DHCP (in Proxmox or VM settings)

> Ensure network interfaces are bridged and DHCP is off.

---

### 5. 🔌 Boot VMs & Generate Netplan

#### Navigate to:

```bash
cd /root/lab-infra/m3/core
```

#### Make `gen-netplan.sh` Executable and Run:

```bash
chmod +x gen-netplan.sh
./gen-netplan.sh
```

**Expected Output:**

```text
✅ Netplan configuration written to /etc/netplan/99-bridges.yaml
🔄 Applying netplan now...
✅ Done. Bridges + VLANs are ready and persistent.
```

---

### 6. 🚀 Initialize FRRouting Folders

```bash
chmod +x init-frr.sh
./init-frr.sh
```

**Expected Output:**

```text
[*] Checking ksa_frr
    Creating ksa_frr
[✅] Initialized ksa_frr
...
[✅] sh() helper added to ~/.bashrc
```

---

### 7. 🧱 Docker Compose Up

```bash
docker compose up -d
```

**Expected Containers:**

```bash
docker ps
```

```text
CONTAINER ID   IMAGE           ...   NAMES
...            frrouting/frr   ...   usa_core
...            frrouting/frr   ...   uae_core
...            frrouting/frr   ...   pak_core
...            frrouting/frr   ...   ksa_core
```

---

### 8. 🔗 Add Uplink IPs to Containers

#### Go to Uplink Directory:

```bash
cd /root/lab-infra/m3/core/uplink
chmod +x uplink.sh
nano uplink.txt   # Optional: verify IP mapping
./uplink.sh
```

**Expected Output:**

```text
[*] Configuring uplink for ksa_core
Cannot find device "veth-ksa-inet"
[+] Uplink for ksa_core on eth0 → 192.168.100.201/24
...
```

---

### 9. ✅ Verify Internet from Containers

```bash
docker exec ksa_core ping 1.1.1.1
docker exec uae_core ping 1.1.1.1
docker exec pak_core ping 1.1.1.1
docker exec usa_core ping 1.1.1.1
```

**Expected Output:**

```text
64 bytes from 1.1.1.1: seq=0 ttl=58 time=30.9 ms
```

> 🔍 Note: Host (VM) does not have internet by design. Internet access is routed **only** via containers.

---

## 📁 Folder Tree Overview

```
lab-infra/
└── m3/
    └── core/
        ├── compose.yml
        ├── config/
        ├── gen-netplan.sh
        ├── init-frr.sh
        ├── ksa_frr/
        ├── pak_frr/
        ├── uae_frr/
        ├── usa_frr/
        ├── uplink/
        │   ├── uplink.sh
        │   └── uplink.txt
        └── verify/
```

---

## 🔻 Step 10: Configure Downlink Interfaces

### 10.1 🧰 Downlink Script Execution

Navigate to the downlink directory:

```bash
cd /root/lab-infra/m3/core/downlink
chmod +x downlink.sh
nano downlink.txt  # Optional: define or review downlink mappings
./downlink.sh
```

**Expected Output:**

```text
[*] Configuring downlink for ksa_core (eth1)
[+] Downlink eth1 in ksa_core → 10.11.0.1/30 on VLAN 11 (br-ksa)
...
[+] Downlink eth3 in usa_core → 10.14.0.9/30 on VLAN 13 (br-usa)
```

---

### 10.2 🔍 Verify Container Interfaces

Example (Repeat for all containers):

```bash
docker exec ksa_core ip -br a
```

**Output:**

```text
eth1@if34        UP             10.11.0.1/30 ...
eth2@if36        UP             10.11.0.5/30 ...
eth3@if38        UP             10.11.0.9/30 ...
```

Each container now has:

* 3 downlink interfaces (`eth1`, `eth2`, `eth3`)
* Bound to VLANs via bridges (`br-ksa`, `br-uae`, etc.)

---

### 10.3 🌍 Test Internet via Downlink Interface

Use source IP (`-I`) to ping from each downlink:

```bash
docker exec ksa_core ping 1.1.1.1 -I 10.11.0.1
```

> ⚠️ If ping hangs or fails, MASQUERADE (NAT) may not be applied yet.

---

### 10.4 🔧 Enable NAT (MASQUERADE) on All Containers

```bash
docker exec ksa_core iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
docker exec uae_core iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
docker exec pak_core iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
docker exec usa_core iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

> 🛑 Make sure container names are typed correctly (e.g., `usa_core`, not `use_core`).

---

### 10.5 🧷 Persist iptables Rules (Optional)

You can save the rules inside the containers:

```bash
docker exec ksa_core iptables-save > /etc/iptables/rules.v4
docker exec uae_core iptables-save > /etc/iptables/rules.v4
docker exec pak_core iptables-save > /etc/iptables/rules.v4
docker exec usa_core iptables-save > /etc/iptables/rules.v4
```
Great — I’ve received your uploaded file: `Core-BGP_Config.txt`. Based on that and your earlier point (that we stopped at `iptables-save` step), here's the **next proper section** to continue from, covering **core BGP configuration** as per the script `configure_core_bgp.sh`.

---

## 🔺 Step 11: Configure BGP on Core Routers

### 11.1 📁 Navigate to BGP Config Script

```bash
cd /root/lab-infra/m3/core/config
chmod +x configure_core_bgp.sh
```

This script reads from `bgp_core_config.txt` and automates BGP setup for each core router:

* `ksa_core`
* `uae_core`
* `pak_core`
* `usa_core`

---

### 11.2 ⚙️ Run the Core BGP Configuration Script

```bash
./configure_core_bgp.sh
```

You should see output indicating configuration of neighbors, remote-AS, and default-originate settings.

**Example Output:**

```text
[*] Configuring BGP on pak_core
[+] Neighbor 10.13.0.2 remote-as 65003
[+] Neighbor 10.13.0.6 remote-as 65003
[+] BGP configuration saved
```

---

### 11.3 ✅ Validate Configuration via vtysh

To inspect manually:

```bash
docker exec -it usa_core vtysh
```

Then inside:

```vtysh
show running
```

Expected BGP configuration should look like this:

```text
router bgp 65004
 bgp router-id 4.4.4.4
 neighbor 10.14.0.2 remote-as 65004
 neighbor 10.14.0.6 remote-as 65004
!
 address-family ipv4 unicast
  neighbor 10.14.0.2 default-originate
  neighbor 10.14.0.6 default-originate
```

> 📌 Each core uses its unique ASN and internal point-to-point subnet (e.g., `10.11.x.x`, `10.12.x.x`, etc.).

---
