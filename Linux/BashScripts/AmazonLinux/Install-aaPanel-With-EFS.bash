#!/bin/bash

# Install aaPanel on Amazon Linux 2023 and back its default web root with AWS EFS.
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
dnf install -y curl wget ca-certificates amazon-efs-utils nfs-utils

# ── Mount EFS ─────────────────────────────────────────────────────────────────
echo "==> Mounting EFS..."
mkdir -p "$EFS_MOUNT_POINT"

if ! grep -q "$EFS_DNS_NAME:/ $EFS_MOUNT_POINT efs" /etc/fstab; then
  echo "$EFS_DNS_NAME:/ $EFS_MOUNT_POINT efs _netdev,tls 0 0" >> /etc/fstab
fi

mount -a
mkdir -p "$EFS_ROOT_DIR"

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

echo "==> aaPanel installed with EFS-backed web root at $AAPANEL_DEFAULT_ROOT"
