#!/bin_bash
# ==========================================================
# Script Otomasi Soal 10 (Full + Revisi Final)
# (Jalankan di Elros)
# ==========================================================

set -e

echo "[1/4] Memastikan resolver sudah benar..."
# Ganti resolver Elros biar bisa 'apt' dan 'resolve' worker
echo "nameserver 192.236.3.2" > /etc/resolv.conf
echo "nameserver 192.236.3.3" >> /etc/resolv.conf

echo "[2/4] Menginstal Nginx..."
apt update > /dev/null
apt install -y nginx > /dev/null

echo "[3/4] Konfigurasi Nginx Load Balancer (elros.k50.com)..."

# Hapus config lama (kalo ada)
rm -f /etc/nginx/sites-available/elros-lb
rm -f /etc/nginx/sites-enabled/elros-lb

# Bikin config file baru
cat > /etc/nginx/sites-available/elros-lb <<EOF
# Upstream block (Soal 10)
upstream kesatria_numenor {
    # Round Robin (default), merata (Soal 10)

    # Pake domain, bukan IP
    server elendil.k50.com:8001;
    server isildur.k50.com:8002;
    server anarion.k50.com:8003;
}

server {
    listen 80;
    server_name elros.k50.com;

    location / {
        # Teruskan ke upstream (Soal 10)
        proxy_pass http://kesatria_numenor;

        # REVISI FINAL: Kirim Host header ASLI (elros.k50.com)
        proxy_set_header Host \$host;

        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo "[4/4] Mengaktifkan site & restart Nginx..."
# Aktifin site baru
ln -s /etc/nginx/sites-available/elros-lb /etc/nginx/sites-enabled/elros-lb 2>/dev/null || true
# Hapus site default
unlink /etc/nginx/sites-enabled/default 2>/dev/null || true

service nginx restart

echo "✅ Selesai. Elros (Load Balancer) sekarang aktif."
echo "Tes dari client (Miriel/Celebrimbor):"
echo "curl http://elros.k50.com/api/airing"
