#!/bin/bash
#  DNS Slave Setup Script - Amdir (192.236.3.3)

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
    type slave;
    masters { 192.236.3.2; };
    file "$ZONE_DIR/$DOMAIN";
};

zone "$REVERSE_ZONE" {
    type slave;
    masters { 192.236.3.2; };
    file "$ZONE_DIR/db.192.236.3";
};
EOF

echo "Membuat file named.conf.options..."
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { any; };

    listen-on port 53 { any; };
    listen-on-v6 { any; };
};
EOF

echo "Restarting bind9..."
service named restart

echo "Menarik data zone dari master..."
rndc retransfer $DOMAIN
rndc retransfer $REVERSE_ZONE

ls -l $ZONE_DIR

echo "DNS Slave (Amdir) selesai dikonfigurasi!"