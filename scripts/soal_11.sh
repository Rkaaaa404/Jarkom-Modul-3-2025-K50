# ====================================================
# Client Attack Script
# ====================================================
apt update
apt install apache2-utils -y

# Serangan awal
ab -n 100 -c 10 http://elros.k50.com/api/airing/

# Serangan Penuh
ab -n 2000 -c 100 http://elros.k50.com/api/airing/

# ===================================================
# Worker monitoring script
# ===================================================

apt update
apt install htop -y

# ===================================================
# Load Balancer monitoring script
# ===================================================

cat /var/log/nginx/error.log
