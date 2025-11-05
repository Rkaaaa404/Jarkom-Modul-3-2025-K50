#!/bin/bash
# ==========================================================
# Script Soal 11 (REVISI FINAL) - Weighted LB
# (Jalankan di Elros)
# ==========================================================

set -e

NGINX_CONF="/etc/nginx/sites-available/elros-lb"

# --- INI YANG DIBENERIN ---
# Variabelnya sekarang cuma nama, BUKAN 'upstream nama'
UPSTREAM_BLOCK="kesatria_numenor"
# --------------------------

echo "Menerapkan Strategi Bertahan (Weighted Round Robin)..."

# Hapus config lama (biar gampang)
rm -f $NGINX_CONF

# Bikin config file baru dengan 'weight'
cat > $NGINX_CONF <<EOF
# Upstream block (Soal 11 - Weighted)
upstream $UPSTREAM_BLOCK {
    # Elendil dapet 3x lipat beban
    server elendil.k50.com:8001 weight=3;
    server isildur.k50.com:8002 weight=1;
    server anarion.k50.com:8003 weight=1;
}

server {
    listen 80;
    server_name elros.k50.com;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo "Config $NGINX_CONF telah di-update dengan 'weight'."

echo "Mengecek syntax Nginx..."
# Safety check
nginx -t

echo "Restarting Nginx..."
service nginx restart

echo "✅ Selesai. Elros (LB) sekarang pake Weighted Round Robin."
echo "Jalankan tes 'Serangan Penuh' lagi dari client:"
echo "ab -n 2000 -c 100 http://elros.k50.com/api/airing/"
