#!/bin/bash
set -e

NGINX_CONF="/etc/nginx/sites-available/laravel"

if [ ! -f "$NGINX_CONF" ]; then
    echo "ERROR: Config $NGINX_CONF tidak ditemukan."
    echo "Jalankan script soal_7.sh dan soal_8.sh dulu."
    exit 1
fi

if grep -q "elros.k50.com" $NGINX_CONF; then
    echo "Config sudah bener (elros.k50.com sudah ada)."
    echo "Restarting Nginx..."
    service nginx restart
    echo "✅ Selesai. Worker $HOSTNAME sudah siap."
    exit 0
fi

echo "Menambahkan 'elros.k50.com' ke server_name di $HOSTNAME..."
sed -i 's/server_name \(.*\);/server_name \1 elros.k50.com;/' $NGINX_CONF

echo "Restarting Nginx..."
service nginx restart

echo "✅ Selesai. Worker $HOSTNAME sudah diperbaiki."