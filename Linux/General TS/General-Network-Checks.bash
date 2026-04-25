#!/bin/bash

# GENERAL NETWORK TROUBLESHOOTING
# Copy and paste the commands you need into a Linux terminal.

# ---------------------------------------------------------------------------
# 1) QUICK HOST AND OS CONTEXT
# ---------------------------------------------------------------------------

hostname
hostname -f
uname -a
cat /etc/os-release
date


# ---------------------------------------------------------------------------
# 2) INTERFACES, IPS, AND ROUTES
# ---------------------------------------------------------------------------

ip addr show
ip -4 addr
ip -6 addr
ip link show
ip route show
ip route show default

# Legacy alternatives if needed
ifconfig -a
route -n


# ---------------------------------------------------------------------------
# 3) GATEWAY AND INTERNET TESTS
# ---------------------------------------------------------------------------

# Replace GATEWAY_IP with your default gateway if you want a direct test.
ping -c 4 GATEWAY_IP
ping -c 4 8.8.8.8
ping -c 4 1.1.1.1

# Test path to a public target.
traceroute 8.8.8.8
tracepath 8.8.8.8


# ---------------------------------------------------------------------------
# 4) LOCAL PORTS AND CONNECTIONS
# ---------------------------------------------------------------------------

sudo ss -tulnp
sudo ss -plant
sudo netstat -tulnp
sudo lsof -i -P -n


# ---------------------------------------------------------------------------
# 5) NIC AND DRIVER DETAILS
# ---------------------------------------------------------------------------

sudo ethtool eth0
sudo ethtool -i eth0
ip -s link


# ---------------------------------------------------------------------------
# 6) FIREWALL QUICK CHECKS
# ---------------------------------------------------------------------------

sudo ufw status verbose
sudo firewall-cmd --state
sudo firewall-cmd --list-all
sudo iptables -L -n -v


# ---------------------------------------------------------------------------
# 7) SYSTEM LOGS RELATED TO NETWORKING
# ---------------------------------------------------------------------------

sudo journalctl -u NetworkManager -n 50 --no-pager
sudo journalctl -u systemd-networkd -n 50 --no-pager
sudo journalctl -u systemd-resolved -n 50 --no-pager
dmesg | grep -iE "eth|ens|enp|link|network"
