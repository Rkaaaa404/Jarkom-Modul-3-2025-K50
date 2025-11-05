#!/bin/bash
# Konfigurasi Minastir sebagai DNS Forwarder

echo "[1/5] Menginstal bind9..."
apt update -y
apt install -y bind9 bind9utils bind9-doc

echo "[2/5] Mengatur konfigurasi /etc/bind/named.conf.options..."
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    forwarders {
        192.168.122.1;
    };

    allow-query { any; };
    listen-on { any; };
    recursion yes;
};
EOF

echo "[3/5] Mengatur resolv.conf untuk menggunakan localhost..."
rm -f /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf

echo "[4/5] Memulai ulang layanan bind9 dengan named..."
service named restart

echo "[5/5] Tes DNS forwarding..."
apt install -y dnsutils >/dev/null 2>&1
dig google.com @127.0.0.1 | grep "status\|SERVER"