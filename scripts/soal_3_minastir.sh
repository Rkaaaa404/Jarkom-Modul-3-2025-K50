#!/bin/bash
# ===============================
# Konfigurasi Forwarder DNS Minastir
# ===============================

echo "[1/5] Updating repository..."
apt update -y

echo "[2/5] Installing Squid proxy..."
apt install squid -y

echo "[3/5] Backing up default config..."
cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

echo "[4/5] Writing new Squid configuration..."
cat > /etc/squid/squid.conf <<'EOF'
# ===============================
# Konfigurasi Squid (Forwarder DNS)
# ===============================

# Port proxy
http_port 3128

# Hanya izinkan jaringan internal 192.236.0.0/16
acl internalnet src 192.236.0.0/16
http_access allow internalnet
http_access deny all

# Log akses
access_log /var/log/squid/access.log

# Gunakan DNS nameserver eksternal sesuai soal
dns_nameservers 192.168.122.1
EOF

echo "[5/5] Restarting Squid service..."
service squid restart

echo
echo "Proxy Minastir telah aktif di port 3128"
echo "Pastikan client menambahkan environment variable berikut:"
echo "export http_proxy=\"http://192.236.5.2:3128\""
echo "export https_proxy=\"http://192.236.5.2:3128\""
echo
echo "Untuk verifikasi, jalankan dari node lain:"
echo "curl -I http://google.com"
echo "Jika berhasil, akan muncul header: 'Via: 1.1 Minastir (squid)'"