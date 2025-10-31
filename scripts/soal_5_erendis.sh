#!/bin/bash
# ============================================
#  DNS Master Setup Script - Erendis (192.236.3.3)
# ============================================

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
cat > /etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";

    recursion yes;
    allow-query { any; };
    allow-transfer { 192.236.3.3; };

    listen-on port 53 { any; };
    listen-on-v6 { any; };
};
EOF

echo "Membuat zona forward ($DOMAIN)..."
cat > $ZONE_DIR/$DOMAIN <<EOF
\$TTL 604800
@   IN  SOA ns1.$DOMAIN. admin.$DOMAIN. (
        2025102901 ; Serial
        604800     ; Refresh
        86400      ; Retry
        2419200    ; Expire
        604800 )   ; Negative Cache TTL

; Name Servers
@   IN  NS  ns1.$DOMAIN.
@   IN  NS  ns2.$DOMAIN.

; A Records
ns1         IN  A 192.236.3.2
ns2         IN  A 192.236.3.3
erendis     IN  A 192.236.3.2
amdir       IN  A 192.236.3.3
elros       IN  A 192.236.1.7
pharazoan   IN  A 192.236.2.2

; Alias
www         IN  CNAME $DOMAIN.

; TXT records (pesan rahasia)
elros       IN  TXT "Cincin Sauron"
pharazoan   IN  TXT "Aliansi Terakhir"
EOF

echo "Membuat zona reverse ($REVERSE_ZONE)..."
cat > $ZONE_DIR/db.192.236.3 <<EOF
\$TTL 604800
@   IN  SOA ns1.$DOMAIN. admin.$DOMAIN. (
        2025102901 ; Serial
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

echo "Restarting bind9..."
service named restart

echo "DNS Master (Erendis) selesai dikonfigurasi!"