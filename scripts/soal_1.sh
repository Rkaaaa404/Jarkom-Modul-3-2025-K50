echo "Mengosongkan /etc/resolv.conf..."
rm /etc/resolv.conf
touch /etc/resolv.conf

echo "Meneruskan paket ke NAT1..."
sysctl -w net.ipv4.ip_forward=1
