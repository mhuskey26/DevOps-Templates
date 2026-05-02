#!/bin/bash

# Configure a chroot SFTP server on Amazon Linux 2023.
# Update the variables below before running.

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
SFTP_GROUP="sftpaccess"
SFTP_USER="sftpuser"                       # Change to the desired username
SFTP_BASE_DIR="/mnt/efs/fs1/SFTP"         # Base directory for SFTP chroot homes
# ──────────────────────────────────────────────────────────────────────────────

if [ "${EUID}" -ne 0 ]; then
  echo "Run this script as root or with sudo."
  exit 1
fi

echo "==> Updating packages..."
dnf update -y
dnf install -y openssh-server

# ── Create SFTP group ─────────────────────────────────────────────────────────
if ! getent group "$SFTP_GROUP" &>/dev/null; then
  groupadd "$SFTP_GROUP"
  echo "==> Created group: $SFTP_GROUP"
fi

# ── Configure sshd for chroot SFTP ───────────────────────────────────────────
SSHD_CONFIG="/etc/ssh/sshd_config"

# Remove any existing Match Group block for this group to avoid duplicates
sed -i "/^Match Group ${SFTP_GROUP}/,/^Match /{ /^Match Group ${SFTP_GROUP}/d; /^[[:space:]]/d }" "$SSHD_CONFIG" 2>/dev/null || true

cat >> "$SSHD_CONFIG" <<EOF

# ── chroot SFTP for group ${SFTP_GROUP} ──────────────────────────────────────
Match Group ${SFTP_GROUP}
    ForceCommand internal-sftp
    PasswordAuthentication yes
    ChrootDirectory %h
    PermitTunnel no
    AllowAgentForwarding no
    AllowTcpForwarding no
    X11Forwarding no
EOF

# ── Validate and reload sshd ──────────────────────────────────────────────────
sshd -t
systemctl enable sshd
systemctl restart sshd
echo "==> sshd reconfigured and restarted."

# ── Create SFTP user ──────────────────────────────────────────────────────────
echo "==> Creating SFTP user: $SFTP_USER"

if ! id "$SFTP_USER" &>/dev/null; then
  useradd --shell /sbin/nologin --no-create-home "$SFTP_USER"
fi

# Chroot home: must be owned by root:root, chmod 755
CHROOT_HOME="$SFTP_BASE_DIR/$SFTP_USER"
mkdir -p "$CHROOT_HOME"
chown root:root "$CHROOT_HOME"
chmod 755 "$CHROOT_HOME"

# Writable uploads directory owned by the user
UPLOAD_DIR="$CHROOT_HOME/files"
mkdir -p "$UPLOAD_DIR"
chown "$SFTP_USER:$SFTP_USER" "$UPLOAD_DIR"
chmod 755 "$UPLOAD_DIR"

# Point the user's home to the chroot directory
usermod -d "$CHROOT_HOME" "$SFTP_USER"
usermod -aG "$SFTP_GROUP" "$SFTP_USER"

# Set a password (prompts interactively)
echo "==> Set password for $SFTP_USER:"
passwd "$SFTP_USER"

# ── firewalld ─────────────────────────────────────────────────────────────────
if systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-service=ssh
  firewall-cmd --reload
fi

echo ""
echo "==> SFTP setup complete."
echo "    User:        $SFTP_USER"
echo "    Chroot home: $CHROOT_HOME"
echo "    Upload dir:  $UPLOAD_DIR"
echo "    Group:       $SFTP_GROUP"
