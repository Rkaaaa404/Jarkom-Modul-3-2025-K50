#!/bin/bash
apt update
apt install bind9 -y

echo "[1/6] Membuat direktori zone..."
mkdir -p /etc/bind/zones

echo "[2/6] Membuat direktori runtime untuk bind..."
mkdir -p /run/named
chmod 777 /run/named

echo "[3/6] Konfigurasi options..."
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";

    // Listening ke semua interface
    listen-on port 53 { any; };
    listen-on-v6 { none; };

    // Izinkan query dari subnet internal
    allow-query { 192.236.0.0/16; };

    recursion yes;
    auth-nxdomain no; // prevent empty zones warning

    forwarders { 192.168.122.1; };
};
EOF

echo "[4/6] Konfigurasi zone master..."
cat > /etc/bind/named.conf.local <<'EOF'
zone "k50.com" {
    type master;
    file "/etc/bind/zones/k50.com";
    allow-transfer { 192.236.3.3; }; // Amdir
};
EOF

echo "[5/6] File zone..."
cat > /etc/bind/zones/k50.com <<'EOF'
$TTL    604800
@   IN  SOA ns1.k50.com. admin.k50.com. (
        2025102801 ; Serial
        604800     ; Refresh
        86400     ; Retry
        2419200   ; Expire
        604800 ) ; Negative Cache TTL

@   IN  NS  ns1.k50.com.
@   IN  NS  ns2.k50.com.

ns1             IN  A   192.236.3.2
ns2             IN  A   192.236.3.3

elendil         IN  A   192.236.1.2
isildur         IN  A   192.236.1.3
anarion         IN  A   192.236.1.4
miriel          IN  A   192.236.1.5
amandil         IN  A   192.236.1.6
elros           IN  A   192.236.1.7

pharazoan       IN  A   192.236.2.2
celebrimbor     IN  A   192.236.2.3
gilgalad        IN  A   192.236.2.4
oropher         IN  A   192.236.2.5
celeborn        IN  A   192.236.2.6
gladriel        IN  A   192.236.2.7

khamul          IN  A   192.236.3.95
erendis         IN  A   192.236.3.2
amdir           IN  A   192.236.3.3

aldarion        IN  A   192.236.4.2
palantir        IN  A   192.236.4.3
narvi           IN  A   192.236.4.4

minastir        IN  A   192.236.5.2
EOF

echo "[6/6] Cek konfigurasi..."
named-checkconf
named-checkzone k50.com /etc/bind/zones/k50.com

service named restart
echo "DNS master Erendis siap!"
