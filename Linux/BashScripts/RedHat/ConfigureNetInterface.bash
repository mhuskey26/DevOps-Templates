#!/bin/bash

# Configure a static network interface on RHEL / Rocky / AlmaLinux 9 using nmcli.
# RHEL 9 uses NetworkManager by default; /etc/sysconfig/network-scripts is legacy.
# Update the variables below before running.

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
INTERFACE="ens192"        # Network interface name (check: ip link show)
STATIC_IP="0.0.0.0/24"   # IP address with CIDR prefix, e.g. 192.168.1.100/24
GATEWAY="0.0.0.0"         # Default gateway, e.g. 192.168.1.1
DNS1="8.8.8.8"
DNS2="8.8.4.4"
DNS3="1.1.1.1"
CONNECTION_NAME="static-$INTERFACE"
# ──────────────────────────────────────────────────────────────────────────────

if [ "${EUID}" -ne 0 ]; then
  echo "Run this script as root or with sudo."
  exit 1
fi

if [ "$STATIC_IP" = "0.0.0.0/24" ]; then
  echo "Update STATIC_IP, GATEWAY, and DNS values before running."
  exit 1
fi

echo "==> Ensuring NetworkManager is installed and running..."
dnf install -y NetworkManager
systemctl enable --now NetworkManager

echo "==> Detecting existing connection for interface: $INTERFACE..."
EXISTING_CON="$(nmcli -t -f NAME,DEVICE con show | grep ":${INTERFACE}$" | cut -d: -f1 || true)"

if [ -n "$EXISTING_CON" ]; then
  echo "==> Removing existing connection: $EXISTING_CON"
  nmcli con delete "$EXISTING_CON"
fi

echo "==> Creating static connection: $CONNECTION_NAME"
nmcli con add \
  type ethernet \
  con-name "$CONNECTION_NAME" \
  ifname "$INTERFACE" \
  ipv4.method manual \
  ipv4.addresses "$STATIC_IP" \
  ipv4.gateway "$GATEWAY" \
  ipv4.dns "$DNS1 $DNS2 $DNS3" \
  ipv6.method ignore \
  connection.autoconnect yes

echo "==> Bringing up connection..."
nmcli con up "$CONNECTION_NAME"

echo "==> Current IP configuration:"
ip addr show "$INTERFACE"
ip route show

# ── SELinux: no changes needed for basic networking ──────────────────────────
# NetworkManager handles SELinux contexts automatically.

# ── firewalld: ensure default zone is set correctly ──────────────────────────
if systemctl is-active --quiet firewalld; then
  echo "==> Setting interface zone in firewalld..."
  firewall-cmd --zone=public --change-interface="$INTERFACE" --permanent
  firewall-cmd --reload
fi

echo "==> Network interface configured."

# ── Persist DNS (optional override) ──────────────────────────────────────────
# NetworkManager manages /etc/resolv.conf automatically when dns= is set above.
# If you need to lock resolv.conf independently, uncomment the block below:
#
# cat > /etc/resolv.conf <<EOF
# nameserver $DNS1
# nameserver $DNS2
# nameserver $DNS3
# EOF
# chattr +i /etc/resolv.conf
