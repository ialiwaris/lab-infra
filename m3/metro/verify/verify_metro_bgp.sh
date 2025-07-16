#!/bin/bash
set -e

METROS=(
    "ksa_jed"
    "ksa_dmm"
    "ksa_ruh"
    "uae_auh"
    "uae_shj"
    "uae_fjr"
    "pak_lhr"
    "pak_khi"
    "pak_isb"
    "usa_ny"
    "usa_dc"
    "usa_ca"
)

GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

printf "%-12s  %-6s  %-6s  %-15s\n" "Site" "Ping" "BGP" "Neighbor"
printf "%-12s  %-6s  %-6s  %-15s\n" "------------" "------" "------" "---------------"

for METRO in "${METROS[@]}"; do
    PING_RAW="FAIL"
    BGP_RAW="FAIL"
    NEIGHBOR_IP="-"

    # Check ping
    if docker exec "$METRO" ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
        PING_RAW="OK"
    fi

    # Check BGP
    SUMMARY=$(docker exec -i "$METRO" vtysh -c "show ip bgp summary")
    if echo "$SUMMARY" | grep -q "Neighbor"; then
        BGP_RAW="OK"
        NEIGHBOR_IP=$(echo "$SUMMARY" | awk '/^[0-9]+\./ {print $1; exit}')
    fi

    # Pad raw text first for alignment
    PING_PADDED=$(printf "%-4s" "$PING_RAW")
    BGP_PADDED=$(printf "%-4s" "$BGP_RAW")

    # Add colors
    if [[ "$PING_RAW" == "OK" ]]; then
        PING_COLORED="${GREEN}${PING_PADDED}${RESET}"
    else
        PING_COLORED="${RED}${PING_PADDED}${RESET}"
    fi

    if [[ "$BGP_RAW" == "OK" ]]; then
        BGP_COLORED="${GREEN}${BGP_PADDED}${RESET}"
    else
        BGP_COLORED="${RED}${BGP_PADDED}${RESET}"
    fi

    printf "%-12s  %-6b  %-6b  %-15s\n" "$METRO" "$PING_COLORED" "$BGP_COLORED" "$NEIGHBOR_IP"
done