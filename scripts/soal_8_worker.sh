#!/bin/bash
# ==========================================================
# Script Otomasi Soal 8 - DB Connect & Nginx Security
# ==========================================================

# Hentikan script jika ada error
set -e

# --- (1) Input Konfigurasi ---
read -p "Masukkan DOMAIN LENGKAP worker ini (e.g., elendil.k50.com): " WORKER_DOMAIN
read -p "Masukkan PORT Nginx worker ini (e.g., 8001): " WORKER_PORT
read -p "Masukkan NAMA DATABASE (e.g., dbkelompokyyy): " DB_NAME
read -p "Masukkan USERNAME DATABASE (e.g., kelompokyyy): " DB_USER
read -s -p "Masukkan PASSWORD DATABASE: " DB_PASS
echo "" # Pindah baris baru setelah input password

LARAVEL_DIR="/var/www/laravel-simple-rest-api"
NGINX_CONF="/etc/nginx/sites-available/laravel"

echo "[1/4] Konfigurasi .env (koneksi database)..."
# Pindah ke direktori Laravel
cd $LARAVEL_DIR

# Pake 'sed' buat ganti isi .env
sed -i "s/DB_HOST=127.0.0.1/DB_HOST=palantir.k50.com/" .env
sed -i "s/DB_DATABASE=laravel/DB_DATABASE=$DB_NAME/" .env
sed -i "s/DB_USERNAME=root/DB_USERNAME=$DB_USER/" .env
sed -i "s/DB_PASSWORD=/DB_PASSWORD=$DB_PASS/" .env

echo "✅ .env terkonfigurasi untuk palantir.k50.com."

# --- (2) Migrasi & Seeding ---
# Cek apakah kita Elendil (berdasarkan domain yg lo masukin)
if [ "$WORKER_DOMAIN" == "elendil.k50.com" ]; then
    echo "[2/4] Node ini Elendil. Menjalankan migrate:fresh --seed..."
    php artisan migrate:fresh --seed
    echo "✅ Database di-migrasi & di-seed."
else
    echo "[2/4] Node ini bukan Elendil. Skip migrasi."
fi

# --- (3) Konfigurasi Nginx (Security) ---
echo "[3/4] Mengunci Nginx (hanya izinkan domain $WORKER_DOMAIN)..."

# Hapus config lama (kalo ada)
rm -f $NGINX_CONF

# Bikin config baru yang udah aman
cat > $NGINX_CONF <<EOF
# Server block ini nangkep request yg pake domain bener
server {
    listen $WORKER_PORT;
    server_name $WORKER_DOMAIN; # <-- Cuma terima domain ini

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
    server_name _; # <-- Nangkep semua sisanya
    return 404; # <-- Tolak
}
EOF

echo "[4/4] Restart Nginx & PHP-FPM..."
service php8.4-fpm restart
service nginx restart

echo "✅ Selesai. Worker $HOSTNAME (port $WORKER_PORT) sekarang terkunci."