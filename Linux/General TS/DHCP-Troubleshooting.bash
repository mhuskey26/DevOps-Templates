#!/bin/bash

# DHCP TROUBLESHOOTING
# Copy and paste the commands you need into a Linux terminal.

# ---------------------------------------------------------------------------
# 1) IDENTIFY ACTIVE INTERFACES AND ADDRESS STATE
# ---------------------------------------------------------------------------

ip addr show
ip route show
nmcli dev status
networkctl status


# ---------------------------------------------------------------------------
# 2) CHECK WHETHER THE INTERFACE HAS A LEASE
# ---------------------------------------------------------------------------

# Replace eth0 if needed.
ip addr show dev eth0
nmcli device show eth0
sudo grep -Ri "lease" /var/lib/NetworkManager/
sudo grep -Ri "lease" /var/lib/dhcp/


# ---------------------------------------------------------------------------
# 3) REQUEST OR RENEW A DHCP LEASE
# ---------------------------------------------------------------------------

# Replace eth0 if needed.
sudo dhclient -v eth0
sudo dhclient -r eth0
sudo dhclient -v eth0

# NetworkManager renew option.
sudo nmcli device reapply eth0
sudo nmcli con up "CONNECTION_NAME"


# ---------------------------------------------------------------------------
# 4) WATCH DHCP-RELATED LOGS
# ---------------------------------------------------------------------------

sudo journalctl -u NetworkManager -n 100 --no-pager
sudo journalctl -u systemd-networkd -n 100 --no-pager
sudo journalctl -xe --no-pager | grep -i dhcp
dmesg | grep -i dhcp


# ---------------------------------------------------------------------------
# 5) VERIFY LAYER 2 AND LOCAL REACHABILITY
# ---------------------------------------------------------------------------

# Replace GATEWAY_IP when known.
ip link show
ip neigh show
ping -c 4 GATEWAY_IP
arp -a


# ---------------------------------------------------------------------------
# 6) PACKET CAPTURE FOR DHCP TRAFFIC
# ---------------------------------------------------------------------------

# Replace eth0 if needed. DHCP uses UDP 67 and 68.
sudo tcpdump -i eth0 -nn port 67 or port 68


# ---------------------------------------------------------------------------
# 7) QUICK DHCP FAILURE CHECKLIST
# ---------------------------------------------------------------------------

# Check for duplicate IPs or conflicts.
sudo arping -D -I eth0 YOUR_EXPECTED_IP

# Restart common networking services.
sudo systemctl restart NetworkManager
sudo systemctl restart systemd-networkd

# Bounce the interface.
sudo ip link set eth0 down
sudo ip link set eth0 up
