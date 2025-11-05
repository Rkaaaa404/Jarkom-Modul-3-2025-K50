#!/bin/bash
# === DHCP RELAY SETUP (Durin) ===
# Prefix: 192.236

PREFIX="192.236"
DHCP_SERVER="${PREFIX}.4.2"   # Aldarion
INTERFACES="eth1 eth2 eth3 eth4"  # ubah sesuai interface ke subnet 1-4

echo "[1/3] Installing DHCP Relay..."

echo "[2/3] Configuring DHCP Relay..."
bash -c "cat > /etc/default/isc-dhcp-relay" <<EOF
SERVERS="${DHCP_SERVER}"
INTERFACES="${INTERFACES}"
OPTIONS=""
EOF

echo "[3/3] Restarting service..."
dhcrelay -d ${DHCP_SERVER} ${INTERFACES} &
sleep 2
ps aux | grep dhcrelay

echo "DHCP Relay setup complete on Durin."
