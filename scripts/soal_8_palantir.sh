#!/bin/bash
# ==========================================================
# Script Setup Palantir (MariaDB Server)
# Kredensial: k50
# ==========================================================

set -e

DB_NAME="db_k50"
DB_USER="user_k50"
DB_PASS="pass_k50"

echo "[1/4] Menginstal MariaDB Server..."
apt update -y
apt install -y mariadb-server > /dev/null

echo "[2/4] Memulai service MariaDB..."
service mariadb start
sleep 2 # Kasih waktu service-nya napas

echo "[3/4] Membuat Database ($DB_NAME) dan User ($DB_USER)..."
# Bikin DB, User (local & remote), dan kasih akses
# Ini ngikutin guide lo
mariadb -e "CREATE DATABASE $DB_NAME;"
mariadb -e "CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"
mariadb -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mariadb -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'%';"
mariadb -e "GRANT ALL PRIVILEGES ON *.* TO '$DB_USER'@'localhost';"
mariadb -e "FLUSH PRIVILEGES;"

echo "[4/4] Mengizinkan koneksi remote (ngedit my.cnf)..."
# Nambahin line ini di bawah [mysqld] sesuai README (5).md
# Ini cara 'sed' yg bener buat nambahin (a - append)
sed -i "/\[mysqld\]/a skip-networking=0\nskip-bind-address" /etc/mysql/my.cnf

# Just in case, comment out bind-address default kalo ada
sed -i "s/^\s*bind-address\s*=\s*127.0.0.1/#bind-address = 127.0.0.1/" /etc/mysql/mariadb.conf.d/50-server.cnf 2>/dev/null || true

echo "Restart MariaDB..."
service mariadb restart

echo "✅ Selesai. Palantir siap di port 3306."
echo "--- Kredensial (simpen buat Soal 8) ---"
echo "   DB_HOST: palantir.k50.com"
echo "   DB_NAME: $DB_NAME"
echo "   DB_USER: $DB_USER"
echo "   DB_PASS: $DB_PASS"