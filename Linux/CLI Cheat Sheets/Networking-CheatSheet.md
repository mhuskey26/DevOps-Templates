# LINUX NETWORKING QUICK CLI SHEET
# Focus: discover, test, configure, update

#Index:
# 1) Discover Current Network State
# 2) Test Connectivity
# 3) Configure Network (Temporary - Until Reboot)
# 4) Update/Persist Network Settings
# 5) DNS Testing and Configuration
# 6) Firewall Port Management

# ---------------------------------------------------------------------------
# 1) DISCOVER CURRENT NETWORK STATE
# ---------------------------------------------------------------------------

# Interfaces and IPs
ip addr show
ip -4 addr
ip -6 addr
ip link show

# Routes and gateway
ip route show
ip route show default

# Display kernel IP routing table
route
route -n
ip route
ip route list
netstat -r
netstat -rn

# Note: Common commands to display kernel IP routing table:
# - `route` - Display routing table (legacy, shows hostnames)
# - `route -n` - Display routing table with numeric IP addresses
# - `ip route` or `ip route show` - Modern method (preferred)
# - `ip route list` - List all routes
# - `netstat -r` - Display routing table (legacy)
# - `netstat -rn` - Display routing table numeric (legacy)

# DNS and host entries
cat /etc/resolv.conf
resolvectl status
cat /etc/hosts

# Open/listening ports
sudo ss -tulnp

# Legacy alternatives
ifconfig -a
route -n
sudo netstat -tulnp


# ---------------------------------------------------------------------------
# 2) TEST CONNECTIVITY
# ---------------------------------------------------------------------------

# Ping gateway / internet / DNS
ping -c 4 GATEWAY_IP
ping -c 4 8.8.8.8
ping -c 4 google.com

# Path and DNS testing
traceroute 8.8.8.8
dig google.com +short
nslookup google.com

# Port connectivity tests
nc -zv TARGET_HOST 22
nc -zv TARGET_HOST 443

# HTTP test
curl -I https://example.com


# ---------------------------------------------------------------------------
# 3) CONFIGURE NETWORK (TEMPORARY - UNTIL REBOOT)
# ---------------------------------------------------------------------------

# Bring interface down/up
sudo ip link set INTERFACE_ID down
sudo ip link set INTERFACE_ID up

# Set IP on interface
sudo ip addr add IP/CIDR dev INTERFACE_ID
sudo ip addr del IP/CIDR dev INTERFACE_ID

# Set default gateway
sudo ip route add default via GATEWAY_IP
sudo ip route del default

# Add/remove network route
sudo ip route add NETWORK/CIDR via GATEWAY_IP
sudo ip route del NETWORK/CIDR

# Set DNS temporarily (systemd-resolved)
sudo resolvectl dns INTERFACE_ID DNS_IP
sudo resolvectl domain INTERFACE_ID DOMAIN_NAME

# Change MAC address
sudo ip link set INTERFACE_ID down
sudo ip link set INTERFACE_ID address NEW_MAC
sudo ip link set INTERFACE_ID up


# ---------------------------------------------------------------------------
# 4) UPDATE/PERSIST NETWORK SETTINGS
# ---------------------------------------------------------------------------

# NetworkManager (RHEL/Fedora/Ubuntu desktop)
nmcli con show
nmcli dev status
sudo nmcli con mod "CONNECTION_NAME" ipv4.addresses "192.168.1.50/24"
sudo nmcli con mod "CONNECTION_NAME" ipv4.gateway "192.168.1.1"
sudo nmcli con mod "CONNECTION_NAME" ipv4.dns "1.1.1.1 8.8.8.8"
sudo nmcli con mod "CONNECTION_NAME" ipv4.method manual
sudo nmcli con up "CONNECTION_NAME"

# Netplan (Ubuntu server)
sudo nano /etc/netplan/00-installer-config.yaml
sudo netplan try
sudo netplan apply

# systemd-networkd
sudo nano /etc/systemd/network/*.network
sudo systemctl restart systemd-networkd


# ---------------------------------------------------------------------------
# 5) DNS TESTING AND CONFIGURATION
# ---------------------------------------------------------------------------

## DNS Testing and Resolution

# Query DNS records
dig DOMAIN_NAME
dig DOMAIN_NAME +short
dig DOMAIN_NAME A
dig DOMAIN_NAME MX
dig DOMAIN_NAME NS
dig DOMAIN_NAME TXT

# Reverse DNS lookup
dig -x IP_ADDRESS
dig -x 8.8.8.8

# Query specific nameserver
dig @NAMESERVER_IP DOMAIN_NAME
dig @8.8.8.8 google.com

# nslookup (interactive/non-interactive)
nslookup DOMAIN_NAME
nslookup DOMAIN_NAME NAMESERVER_IP
nslookup -type=MX DOMAIN_NAME

# host command (simple DNS lookup)
host DOMAIN_NAME
host -t MX DOMAIN_NAME
host -a DOMAIN_NAME

# Check local DNS resolver cache
resolvectl query DOMAIN_NAME
resolvectl status

# Get all DNS records for domain
getent hosts DOMAIN_NAME

# Test DNS response time
time dig DOMAIN_NAME +stats

## DNS Configuration

# View current DNS settings
cat /etc/resolv.conf
resolvectl status
nmcli dev show | grep DNS

# Set DNS temporarily (systemd-resolved)
sudo resolvectl dns INTERFACE_ID 1.1.1.1 8.8.8.8
sudo resolvectl domain INTERFACE_ID example.com
sudo resolvectl dnssec off INTERFACE_ID

# Configure DNS with NetworkManager
sudo nmcli con mod "CONNECTION_NAME" ipv4.dns "1.1.1.1 8.8.8.8"
sudo nmcli con mod "CONNECTION_NAME" ipv4.dns-search "example.com"
sudo nmcli con up "CONNECTION_NAME"

# Edit resolv.conf directly (manual, not persistent on systemd-resolved)
sudo nano /etc/resolv.conf
# Add: nameserver 1.1.1.1
# Add: nameserver 8.8.8.8
# Add: search example.com

# Configure DNS in Netplan (Ubuntu server)
sudo nano /etc/netplan/00-installer-config.yaml
# Add:
# ethernets:
#   eth0:
#     dhcp4: true
#     nameservers:
#       addresses: [1.1.1.1, 8.8.8.8]
#       search: [example.com]
sudo netplan apply

# Flush DNS cache
sudo systemctl restart systemd-resolved
sudo resolvectl flush-caches

# View DNS cache statistics
resolvectl statistics

# Test DNS resolution
nslookup google.com
dig google.com
host google.com


# ---------------------------------------------------------------------------
# 6) FIREWALL PORT MANAGEMENT
# ---------------------------------------------------------------------------

# UFW (Ubuntu/Debian)
sudo ufw status
sudo ufw allow 22/tcp
sudo ufw deny 22/tcp

# firewalld (RHEL/CentOS/Fedora)
sudo firewall-cmd --list-ports
sudo firewall-cmd --add-port=22/tcp --permanent
sudo firewall-cmd --remove-port=22/tcp --permanent
sudo firewall-cmd --reload