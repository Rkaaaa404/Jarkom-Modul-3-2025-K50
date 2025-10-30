#!/bin/bash
# === DHCP SERVER SETUP (Aldarion) ===
# Prefix: 192.236

PREFIX="192.236"
INTERFACE="eth0"   # ubah sesuai interface Aldarion yang terhubung ke subnet 1
DNS_MASTER="${PREFIX}.3.3"   # Erendis (DNS Master)

echo "[1/5] Installing ISC DHCP Server..."
apt update -y
apt install -y isc-dhcp-server

echo "[2/5] Configuring DHCP Server..."
bash -c "cat > /etc/dhcp/dhcpd.conf" <<EOF
# DHCP configuration for The Last Alliance

default-lease-time 600;
max-lease-time 7200;
authoritative;

# Subnet 1 (Human Clients)
subnet ${PREFIX}.1.0 netmask 255.255.255.0 {
  range ${PREFIX}.1.6 ${PREFIX}.1.34;
  range ${PREFIX}.1.68 ${PREFIX}.1.94;
  option routers ${PREFIX}.1.1;
  option broadcast-address ${PREFIX}.1.255;
  option domain-name-servers ${DNS_MASTER};
}

# Subnet 2 (Elf Clients)
subnet ${PREFIX}.2.0 netmask 255.255.255.0 {
  range ${PREFIX}.2.35 ${PREFIX}.2.67;
  range ${PREFIX}.2.96 ${PREFIX}.2.121;
  option routers ${PREFIX}.2.1;
  option broadcast-address ${PREFIX}.2.255;
  option domain-name-servers ${DNS_MASTER};
}

# Subnet 3 (Database / Fixed)
subnet ${PREFIX}.3.0 netmask 255.255.255.0 {
  # Fixed address for Khamul
  host khamul {
    hardware ethernet 02:42:04:df:0f:00;  # MAC address Khamul
    fixed-address ${PREFIX}.3.95;
  }
  option routers ${PREFIX}.3.1;
  option broadcast-address ${PREFIX}.3.255;
  option domain-name-servers ${DNS_MASTER};
}

# Subnet ke-4 (link ke Minastir / Forward Proxy)
subnet 192.236.4.0 netmask 255.255.255.0 {
  # Semua host statis (Aldarion, Palantir, Narvi)
  option routers 192.236.4.1;
  option broadcast-address 192.236.4.255;
  option domain-name-servers 192.236.4.2;
}
EOF

echo "[3/5] Binding DHCP Server to interface ${INTERFACE}..."
sed -i "s/^INTERFACESv4=.*/INTERFACESv4=\"${INTERFACE}\"/" /etc/default/isc-dhcp-server

echo "[4/5] Preparing lease database and starting DHCP Server manually..."
mkdir -p /var/lib/dhcp
touch /var/lib/dhcp/dhcpd.leases

dhcpd -4 -f -d ${INTERFACE} &
sleep 2
ps aux | grep dhcpd

echo "[5/5] Verifying status..."
echo "DHCP Server setup complete on Aldarion."
