#!/bin/bash

# Install aaPanel on Ubuntu and back its default web root with AWS EFS.
# Update the variables below before running.

set -euo pipefail

EFS_DNS_NAME="fs-xxxxxxxx.efs.us-east-1.amazonaws.com"
EFS_MOUNT_POINT="/mnt/efs"
EFS_ROOT_DIR="$EFS_MOUNT_POINT/wwwroot"
AAPANEL_DEFAULT_ROOT="/www/wwwroot"
PANEL_INSTALL_URL="https://www.aapanel.com/script/install_panel_en.sh"

if [ "${EUID}" -ne 0 ]; then
  echo "Run this script as root or with sudo."
  exit 1
fi

if [ "$EFS_DNS_NAME" = "fs-xxxxxxxx.efs.us-east-1.amazonaws.com" ]; then
  echo "Update EFS_DNS_NAME before running this script."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y curl wget ca-certificates nfs-common

mkdir -p "$EFS_MOUNT_POINT"

if ! grep -q "$EFS_DNS_NAME:/ $EFS_MOUNT_POINT nfs4" /etc/fstab; then
  echo "$EFS_DNS_NAME:/ $EFS_MOUNT_POINT nfs4 defaults,_netdev,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport 0 0" >> /etc/fstab
fi

mount -a
mkdir -p "$EFS_ROOT_DIR"

URL="$PANEL_INSTALL_URL"
if [ -f /usr/bin/curl ]; then
  curl -ksSO "$URL"
else
  wget --no-check-certificate -O install_panel_en.sh "$URL"
fi

bash install_panel_en.sh ipssl

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

if id www >/dev/null 2>&1; then
  chown -R www:www "$EFS_ROOT_DIR"
fi

echo
echo "aaPanel installation is complete."
echo "aaPanel default web root now points to: $AAPANEL_DEFAULT_ROOT"
echo "EFS-backed target directory: $EFS_ROOT_DIR"
echo "Confirm the mount with: df -h | grep $EFS_MOUNT_POINT"
echo "Confirm the root link with: ls -ld $AAPANEL_DEFAULT_ROOT"