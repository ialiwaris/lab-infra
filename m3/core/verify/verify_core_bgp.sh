#!/bin/bash
set -e

CORES=(
    "ksa_core"
    "uae_core"
    "pak_core"
    "usa_core"
)

GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

ok() {
    echo -e "${GREEN}OK${RESET}"
}

fail() {
    echo -e "${RED}FAIL${RESET}"
}

printf "%-12s %-8s %-8s %-20s\n" "Site" "Ping" "BGP" "Neighbors"
printf "%-12s %-8s %-8s %-20s\n" "------------" "--------" "--------" "--------------------"

for CORE in "${CORES[@]}"; do
    PING_STATUS=$(fail)
    BGP_STATUS=$(fail)
    NEIGHBORS="-"

    # Check ping to 1.1.1.1
    if docker exec "$CORE" ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
        PING_STATUS=$(ok)
    fi

    # Check BGP neighbors
    SUMMARY=$(docker exec -i "$CORE" vtysh -c "show ip bgp summary")
    if echo "$SUMMARY" | grep -q "Neighbor"; then
        BGP_STATUS=$(ok)
        NEIGHBORS=$(echo "$SUMMARY" | awk '/^[0-9]+\./ {print $1}' | paste -sd "," -)
    fi

    printf "%-12s %-8b %-8b %-20s\n" "$CORE" "$PING_STATUS" "$BGP_STATUS" "$NEIGHBORS"
done