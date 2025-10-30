#!/bin/bash
apt update
apt install bind9 -y

echo "[1/5] Membuat direktori zone..."
mkdir -p /etc/bind/zones

echo "[2/5] Direktori runtime..."
mkdir -p /run/named
chmod 777 /run/named

echo "[3/5] named.conf.options"
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";

    listen-on port 53 { any; };
    listen-on-v6 { none; };
    allow-query { 192.236.0.0/16; };
    recursion yes;
};
EOF

echo "[4/5] Zone slave..."
cat > /etc/bind/named.conf.local <<'EOF'
zone "k50.com" {
    type slave;
    masters { 192.236.3.3; }; # Erendis
    file "/etc/bind/zones/k50.com";
};
EOF

echo "[5/5] Cek konfigurasi..."
named-checkconf

service named restart
echo "DNS slave Amdir siap!"