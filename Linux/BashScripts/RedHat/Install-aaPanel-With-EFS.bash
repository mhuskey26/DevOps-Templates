#!/bin/bash

# Install aaPanel on RHEL / Rocky / AlmaLinux 9 and back its default web root with AWS EFS.
# Update the variables below before running.

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
EFS_DNS_NAME="fs-xxxxxxxx.efs.us-east-1.amazonaws.com"
EFS_MOUNT_POINT="/mnt/efs"
EFS_ROOT_DIR="$EFS_MOUNT_POINT/wwwroot"
AAPANEL_DEFAULT_ROOT="/www/wwwroot"
PANEL_INSTALL_URL="https://www.aapanel.com/script/install_panel_en.sh"
# ──────────────────────────────────────────────────────────────────────────────

if [ "${EUID}" -ne 0 ]; then
  echo "Run this script as root or with sudo."
  exit 1
fi

if [ "$EFS_DNS_NAME" = "fs-xxxxxxxx.efs.us-east-1.amazonaws.com" ]; then
  echo "Update EFS_DNS_NAME before running this script."
  exit 1
fi

echo "==> Updating packages..."
dnf update -y
dnf install -y curl wget ca-certificates nfs-utils

# ── Mount EFS over NFS4 (RHEL does not include amazon-efs-utils by default) ───
# For TLS mount support on RHEL, install amazon-efs-utils from:
#   https://github.com/aws/efs-utils
# and replace the fstab entry with: efs _netdev,tls
echo "==> Mounting EFS via NFS4..."
mkdir -p "$EFS_MOUNT_POINT"

if ! grep -q "$EFS_DNS_NAME:/ $EFS_MOUNT_POINT nfs4" /etc/fstab; then
  echo "$EFS_DNS_NAME:/ $EFS_MOUNT_POINT nfs4 defaults,_netdev,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" >> /etc/fstab
fi

mount -a
mkdir -p "$EFS_ROOT_DIR"

# ── SELinux: allow NFS mounts to be used by web services ─────────────────────
if command -v setsebool &>/dev/null; then
  setsebool -P httpd_use_nfs 1 2>/dev/null || true
fi

# ── Install aaPanel ───────────────────────────────────────────────────────────
echo "==> Downloading aaPanel installer..."
if command -v curl &>/dev/null; then
  curl -ksSO "$PANEL_INSTALL_URL"
else
  wget --no-check-certificate -O install_panel_en.sh "$PANEL_INSTALL_URL"
fi

echo "==> Installing aaPanel..."
bash install_panel_en.sh ipssl

# ── Link EFS as aaPanel web root ──────────────────────────────────────────────
mkdir -p "$EFS_ROOT_DIR"

if [ -d "$AAPANEL_DEFAULT_ROOT" ] && [ ! -L "$AAPANEL_DEFAULT_ROOT" ]; then
  BACKUP_DIR="${AAPANEL_DEFAULT_ROOT}.local-backup-$(date +%Y%m%d%H%M%S)"
  mv "$AAPANEL_DEFAULT_ROOT" "$BACKUP_DIR"

  if [ -z "$(ls -A "$EFS_ROOT_DIR")" ]; then
    cp -a "$BACKUP_DIR"/. "$EFS_ROOT_DIR"/
  fi
fi

rm -rf "$AAPANEL_DEFAULT_ROOT"
ln -s "$EFS_ROOT_DIR" "$AAPANEL_DEFAULT_ROOT"

# ── Fix ownership ──────────────────────────────────────────────────────────────
if id www &>/dev/null; then
  chown -R www:www "$EFS_ROOT_DIR"
fi

# ── firewalld: open aaPanel port ──────────────────────────────────────────────
if systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-port=7800/tcp   # aaPanel default port
  firewall-cmd --permanent --add-service=http
  firewall-cmd --permanent --add-service=https
  firewall-cmd --reload
fi

echo "==> aaPanel installed with EFS-backed web root at $AAPANEL_DEFAULT_ROOT"
