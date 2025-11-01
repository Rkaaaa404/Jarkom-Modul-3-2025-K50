#!/bin/bash
# ==========================================================
# Script Otomasi Setup Laravel Worker
# ==========================================================

set -e

# Ganti sesuai node
NGINX_PORT=8001

echo "[1/5] Menginstal tools dasar..."
apt update > /dev/null
apt install -y lsb-release apt-transport-https ca-certificates wget nginx git > /dev/null

echo "[2/5] Menambah repository Sury PHP & menginstal PHP 8.4..."
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg > /dev/null 2>&1
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list > /dev/null
apt update > /dev/null
apt install -y php8.4-fpm php8.4-mbstring php8.4-xml php8.4-cli php8.4-common php8.4-intl php8.4-opcache php8.4-readline php8.4-mysql php8.4-curl unzip > /dev/null

echo "[3/5] Menginstal Composer..."
wget https://getcomposer.org/download/2.0.13/composer.phar > /dev/null 2>&1
chmod +x composer.phar
mv composer.phar /usr/bin/composer

echo "[4/5] Mengambil Laravel & dependensi..."
cd /var/www
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git > /dev/null 2>&1
cd laravel-simple-rest-api
composer update --no-interaction --no-dev --prefer-dist > /dev/null
cp .env.example .env
php artisan key:generate

echo "[5/5] Konfigurasi Nginx untuk port $NGINX_PORT..."
cat > /etc/nginx/sites-available/laravel <<EOF
server {
    listen $NGINX_PORT;
    root /var/www/laravel-simple-rest-api/public;
    index index.php index.html index.htm;
    server_name _;

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
EOF

ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel 2>/dev/null || true
unlink /etc/nginx/sites-enabled/default 2>/dev/null || true
chown -R www-data:www-data /var/www/laravel-simple-rest-api/storage

service php8.4-fpm start
service nginx restart

echo "✅ Selesai. Worker $HOSTNAME berjalan di port $NGINX_PORT."
echo "Tes dari client: lynx http://$(hostname -I | cut -d' ' -f1):$NGINX_PORT"