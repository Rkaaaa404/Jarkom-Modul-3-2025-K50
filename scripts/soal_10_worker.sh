#!/bin/bash
# ==========================================================
# Script Revisi Final Worker (Jalankan di Elendil, Isildur, Anarion)
# Nuke & Overwrite config Nginx dengan setting yang benar
# ==========================================================

set -e

NGINX_CONF="/etc/nginx/sites-available/laravel"
LARAVEL_DIR="/var/www/laravel-simple-rest-api"

# Deteksi kita ada di node mana
CURRENT_HOST=$(hostname)
DOMAIN_NAME=""
WORKER_PORT=""

if [ "$CURRENT_HOST" == "Elendil" ]; then
    DOMAIN_NAME="elendil.k50.com"
    WORKER_PORT="8001"
elif [ "$CURRENT_HOST" == "Isildur" ]; then
    DOMAIN_NAME="isildur.k50.com"
    WORKER_PORT="8002"
elif [ "$CURRENT_HOST" == "Anarion" ]; then
    DOMAIN_NAME="anarion.k50.com"
    WORKER_PORT="8003"
else
    echo "ERROR: Script ini cuma boleh dijalanin di Elendil, Isildur, or Anarion."
    exit 1
fi

echo "Node terdeteksi: $CURRENT_HOST ($DOMAIN_NAME)"
echo "Menimpa (overwrite) config $NGINX_CONF..."

# Hapus config lama
rm -f $NGINX_CONF

# Bikin config baru yang udah 100% bener
cat > $NGINX_CONF <<EOF
# Server block ini nangkep request yg PAKE DOMAIN BENER
server {
    listen $WORKER_PORT;

    # INI KUNCINYA:
    # Nerima domain sendiri (e.g., elendil.k50.com)
    # DAN domain Load Balancer (elros.k50.com)
    server_name $DOMAIN_NAME elros.k50.com;

    root $LARAVEL_DIR/public;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }

    location ~ /\.ht {
        deny all;
    }
}

# Server block ini nangkep 'sampah' (request via IP)
server {
    listen $WORKER_PORT default_server; # <-- Nangkep yg gak match
    server_name _;
    return 404; # <-- Tolak
}
EOF

echo "Restarting Nginx..."
service nginx restart

echo "✅ Selesai. Worker $HOSTNAME sudah difix."
