#!/bin/bash
#  DNS Master Setup Script - Erendis (192.236.3.2)

DOMAIN="k50.com"
REVERSE_ZONE="3.236.192.in-addr.arpa"
ZONE_DIR="/etc/bind/zones"

echo "Membuat direktori zona..."
mkdir -p $ZONE_DIR
chown bind:bind $ZONE_DIR
chmod 775 $ZONE_DIR

echo "Membuat file named.conf.local..."
cat > /etc/bind/named.conf.local <<EOF
zone "$DOMAIN" {
    type master;
    file "$ZONE_DIR/$DOMAIN";
    allow-transfer { 192.236.3.3; };
};

zone "$REVERSE_ZONE" {
    type master;
    file "$ZONE_DIR/db.192.236.3";
    allow-transfer { 192.236.3.3; };
};
EOF

echo "Membuat file named.conf.options..."
cat > /etc/bind/named.conf.options <<EOL
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { any; };
    allow-transfer { 192.236.3.3; };

    listen-on port 53 { any; };
    listen-on-v6 { any; };
};
EOL

echo "Membuat zona forward ($DOMAIN)..."
cat >> $ZONE_DIR/$DOMAIN <<EOF

; Alias
www         IN  CNAME $DOMAIN.

; TXT records (pesan rahasia)
elros       IN  TXT "Cincin Sauron"
pharazon   IN  TXT "Aliansi Terakhir"
EOF

echo "Membuat zona reverse ($REVERSE_ZONE)..."
cat > $ZONE_DIR/db.192.236.3 <<EOF
\$TTL 604800
@   IN  SOA ns1.$DOMAIN. admin.$DOMAIN. (
        2025102801 ; Serial
        604800     ; Refresh
        86400      ; Retry
        2419200    ; Expire
        604800 )   ; Negative Cache TTL

; Name Servers
@   IN  NS  ns1.$DOMAIN.
@   IN  NS  ns2.$DOMAIN.

; Reverse PTR
2   IN  PTR erendis.$DOMAIN.
3   IN  PTR amdir.$DOMAIN.
EOF

# Update serial number setiap kali ada perubahan
SERIAL=$(date +%Y%m%d01)
sed -i "s/2025102801/$SERIAL/" $ZONE_DIR/$DOMAIN

echo "Restarting bind9..."
service named restart

echo "DNS Master (Erendis) selesai dikonfigurasi!"