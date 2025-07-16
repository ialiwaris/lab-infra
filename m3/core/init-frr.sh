#!/bin/bash
set -e

# Check & install Docker if missing
if ! command -v docker >/dev/null 2>&1; then
    echo "[*] Docker not found, installing…"
    curl -fsSL https://get.docker.com | bash
    echo "[✅] Docker installed"
else
    echo "[ℹ️] Docker already installed, skipping."
fi
# UID and GID of the FRR user inside the container
FRR_UID=100   # adjust if needed
FRR_GID=101   # adjust if needed

for region in ksa uae pak usa; do
    folder="${region}_frr"
    echo "[*] Checking $folder"

    # create folder if missing
    if [ ! -d "$folder" ]; then
        echo "    Creating $folder"
        mkdir -p "$folder"
    fi

    # create vtysh.conf
    echo "service integrated-vtysh-config" > "$folder/vtysh.conf"

    # create daemons
    cat > "$folder/daemons" <<EOF
zebra=yes
bgpd=yes
ospfd=yes
EOF

    # set permissions
    chown -R $FRR_UID:$FRR_GID "$folder"
    chmod 644 "$folder"/vtysh.conf "$folder"/daemons

    echo "[✅] Initialized $folder"
done

echo "[🎉] All FRR folders initialized"
# Append sh() helper to ~/.bashrc if not already present
if ! grep -q "function sh()" ~/.bashrc; then
    echo "[*] Adding sh() helper to ~/.bashrc"
    cat >> ~/.bashrc <<'EOF'

# Docker container shell helper
function sh() {
    if [ -z "$1" ]; then
        echo "Usage: sh <container_name>"
        return 1
    fi
    docker exec -it "$1" bash
}
_sh_complete() {
    COMPREPLY=($(docker ps --format '{{.Names}}' | grep "^${COMP_WORDS[1]}"))
}
complete -F _sh_complete sh

EOF
    echo "[✅] sh() helper added to ~/.bashrc"
else
    echo "[ℹ️] sh() helper already exists in ~/.bashrc"
fi