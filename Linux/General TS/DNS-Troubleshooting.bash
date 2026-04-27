#!/bin/bash

# DNS TROUBLESHOOTING
# Copy and paste the commands you need into a Linux terminal.

# ---------------------------------------------------------------------------
# 1) VIEW CURRENT DNS CONFIGURATION
# ---------------------------------------------------------------------------

cat /etc/resolv.conf
cat /etc/hosts
resolvectl status
nmcli dev show | grep -i dns


# ---------------------------------------------------------------------------
# 2) TEST BASIC NAME RESOLUTION
# ---------------------------------------------------------------------------

getent hosts google.com #uses system's configured name resolution, including /etc/nsswitch.conf
nslookup google.com #older tool, less preferred for troubleshooting but still widely used and available
dig google.com #better and preffered for trobleshooting dns issues
host google.com #a lot like nslookup but more concise output


# ---------------------------------------------------------------------------
# 3) TEST SPECIFIC RECORD TYPES
# ---------------------------------------------------------------------------

dig google.com +short
dig google.com A
dig google.com AAAA
dig google.com MX
dig google.com NS
dig google.com TXT


# ---------------------------------------------------------------------------
# 4) TEST AGAINST A SPECIFIC DNS SERVER
# ---------------------------------------------------------------------------

# Replace DNS_SERVER_IP and DOMAIN_NAME.
nslookup DOMAIN_NAME DNS_SERVER_IP
dig @DNS_SERVER_IP DOMAIN_NAME
dig @8.8.8.8 google.com
dig @1.1.1.1 google.com


# ---------------------------------------------------------------------------
# 5) REVERSE LOOKUPS
# ---------------------------------------------------------------------------

# Replace IP_ADDRESS.
dig -x IP_ADDRESS
host IP_ADDRESS


# ---------------------------------------------------------------------------
# 6) RESPONSE TIME AND PATH CHECKS
# ---------------------------------------------------------------------------

time dig google.com +stats
ping -c 4 google.com
traceroute google.com


# ---------------------------------------------------------------------------
# 7) CACHE AND RESOLVER HEALTH
# ---------------------------------------------------------------------------

resolvectl statistics
resolvectl query google.com
sudo resolvectl flush-caches
sudo systemctl restart systemd-resolved


# ---------------------------------------------------------------------------
# 8) COMMON QUICK FIXES
# ---------------------------------------------------------------------------

# Temporarily set DNS on a systemd-resolved interface.
# Replace INTERFACE_ID as needed.
sudo resolvectl dns INTERFACE_ID 1.1.1.1 8.8.8.8
sudo resolvectl domain INTERFACE_ID '~.'

# NetworkManager DNS update example.
# Replace CONNECTION_NAME.
sudo nmcli con mod "CONNECTION_NAME" ipv4.dns "1.1.1.1 8.8.8.8"
sudo nmcli con up "CONNECTION_NAME"
