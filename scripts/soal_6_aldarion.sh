#!/bin/bash

# Konfigurasi DHCP Aldarion (aturan waktu peminjaman tanah)

echo "Membuat konfigurasi DHCP (/etc/dhcp/dhcpd.conf)..."

cat > /etc/dhcp/dhcpd.conf <<'EOF'

# DHCP configuration for The Last Alliance

authoritative;

# Batas waktu maksimal peminjaman (1 jam)

max-lease-time 3600;

# Subnet 1 (Keluarga Manusia) lease 30 menit

subnet 192.236.1.0 netmask 255.255.255.0 {
range 192.236.1.6 192.236.1.34;
range 192.236.1.68 192.236.1.94;
option routers 192.236.1.1;
option broadcast-address 192.236.1.255;
option domain-name-servers 192.236.3.2, 192.236.3.3;
default-lease-time 1800;
}

# Subnet 2 (Keluarga Peri) lease 10 menit

subnet 192.236.2.0 netmask 255.255.255.0 {
range 192.236.2.35 192.236.2.67;
range 192.236.2.96 192.236.2.121;
option routers 192.236.2.1;
option broadcast-address 192.236.2.255;
option domain-name-servers 192.236.3.2, 192.236.3.3;
default-lease-time 600;
}

# Subnet 3 (Database / Fixed)

subnet 192.236.3.0 netmask 255.255.255.0 {
host khamul {
hardware ethernet 02:42:04:df:0f:00;
fixed-address 192.236.3.95;
}
option routers 192.236.3.1;
option broadcast-address 192.236.3.255;
option domain-name-servers 192.236.3.2;
}

# Subnet 4 (Proxy / Static)

subnet 192.236.4.0 netmask 255.255.255.0 {
option routers 192.236.4.1;
option broadcast-address 192.236.4.255;
option domain-name-servers 192.236.4.2;
}
EOF

echo "Mengecek konfigurasi DHCP..."
dhcpd -t -cf /etc/dhcp/dhcpd.conf

if [ $? -eq 0 ]; then
echo "Konfigurasi valid. Me-restart DHCP server..."
service isc-dhcp-server restart
echo "DHCP server berhasil dijalankan."
else
echo "Ada kesalahan pada konfigurasi DHCP. Cek kembali file /etc/dhcp/dhcpd.conf."
fi