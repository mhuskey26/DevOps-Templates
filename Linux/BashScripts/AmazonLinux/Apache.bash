#!/bin/bash

# Install and configure Apache (httpd) with PHP-FPM on Amazon Linux 2023.
# Intended for a WordPress site backed by EFS and an external RDS/Aurora database.
# Update the variables below before running.

set -euo pipefail

exec > >(tee /var/log/apache-bootstrap.log | logger -t apache-bootstrap -s 2>/dev/console) 2>&1

# ── Configuration ─────────────────────────────────────────────────────────────
EFS_DNS_NAME="fs-xxxxxxxx.efs.us-east-1.amazonaws.com"
SITE_DOMAIN="example.com"
WEB_ROOT="/var/www/html"
EFS_MOUNT_POINT="/mnt/efs"
SHARED_WP_CONTENT="$EFS_MOUNT_POINT/wp-content"
WP_DB_NAME="wordpress"
WP_DB_USER="wp_user"
WP_DB_PASSWORD="change-me"
WP_DB_HOST="wordpress.cluster-xxxxxxxx.us-east-1.rds.amazonaws.com"
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

echo "==> Installing Apache, PHP 8.2, and utilities..."
dnf install -y \
  httpd \
  mod_ssl \
  curl \
  tar \
  unzip \
  amazon-efs-utils \
  nfs-utils \
  php8.2 \
  php8.2-cli \
  php8.2-common \
  php8.2-curl \
  php8.2-fpm \
  php8.2-gd \
  php8.2-intl \
  php8.2-mbstring \
  php8.2-mysqlnd \
  php8.2-opcache \
  php8.2-soap \
  php8.2-xml \
  php8.2-zip \
  mariadb105

# ── Mount EFS ─────────────────────────────────────────────────────────────────
echo "==> Mounting EFS..."
mkdir -p "$WEB_ROOT" "$EFS_MOUNT_POINT"

if ! grep -q "$EFS_DNS_NAME:/ $EFS_MOUNT_POINT efs" /etc/fstab; then
  echo "$EFS_DNS_NAME:/ $EFS_MOUNT_POINT efs _netdev,tls 0 0" >> /etc/fstab
fi

mount -a
mkdir -p "$SHARED_WP_CONTENT/uploads" "$SHARED_WP_CONTENT/plugins" "$SHARED_WP_CONTENT/themes"

# ── Download WordPress ────────────────────────────────────────────────────────
if [ ! -f "$WEB_ROOT/wp-load.php" ]; then
  echo "==> Downloading WordPress..."
  curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz
  tar -xzf /tmp/wordpress.tar.gz -C /tmp
  cp -a /tmp/wordpress/. "$WEB_ROOT/"
  rm -rf /tmp/wordpress /tmp/wordpress.tar.gz
fi

# ── Link shared wp-content from EFS ───────────────────────────────────────────
if [ -d "$WEB_ROOT/wp-content" ] && [ ! -L "$WEB_ROOT/wp-content" ]; then
  if [ -z "$(ls -A "$SHARED_WP_CONTENT")" ]; then
    cp -a "$WEB_ROOT/wp-content"/. "$SHARED_WP_CONTENT"/
  fi
  rm -rf "$WEB_ROOT/wp-content"
fi
[ -L "$WEB_ROOT/wp-content" ] || ln -s "$SHARED_WP_CONTENT" "$WEB_ROOT/wp-content"

# ── Apache vhost config ────────────────────────────────────────────────────────
echo "==> Writing Apache vhost config..."
cat > /etc/httpd/conf.d/wordpress.conf <<'EOF'
<VirtualHost *:80>
    ServerName _default_
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:/run/php-fpm/www.sock|fcgi://localhost"
    </FilesMatch>

    DirectoryIndex index.php index.html
    ErrorLog  /var/log/httpd/wordpress-error.log
    CustomLog /var/log/httpd/wordpress-access.log combined
</VirtualHost>
EOF

# ── PHP-FPM: use Unix socket and run as apache ────────────────────────────────
sed -i 's|^listen = .*|listen = /run/php-fpm/www.sock|'       /etc/php-fpm.d/www.conf
sed -i 's|^;listen.owner = .*|listen.owner = apache|'         /etc/php-fpm.d/www.conf
sed -i 's|^;listen.group = .*|listen.group = apache|'         /etc/php-fpm.d/www.conf
sed -i 's|^user = apache|user = apache|'                       /etc/php-fpm.d/www.conf
sed -i 's|^group = apache|group = apache|'                     /etc/php-fpm.d/www.conf

# ── wp-config.php ─────────────────────────────────────────────────────────────
if [ ! -f "$WEB_ROOT/wp-config.php" ]; then
  echo "==> Writing wp-config.php..."
  SALTS="$(curl -fsSL https://api.wordpress.org/secret-key/1.1/salt/ || true)"
  cat > "$WEB_ROOT/wp-config.php" <<EOF
<?php
define( 'DB_NAME',     '${WP_DB_NAME}' );
define( 'DB_USER',     '${WP_DB_USER}' );
define( 'DB_PASSWORD', '${WP_DB_PASSWORD}' );
define( 'DB_HOST',     '${WP_DB_HOST}' );
define( 'DB_CHARSET',  'utf8mb4' );
define( 'DB_COLLATE',  '' );

${SALTS}

\$table_prefix = 'wp_';
define( 'WP_DEBUG', false );

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
EOF
fi

# ── Permissions ───────────────────────────────────────────────────────────────
chown -R apache:apache "$WEB_ROOT"
find "$WEB_ROOT" -type d -exec chmod 755 {} +
find "$WEB_ROOT" -type f -exec chmod 644 {} +
chmod 640 "$WEB_ROOT/wp-config.php"

# ── firewalld ─────────────────────────────────────────────────────────────────
echo "==> Opening firewall ports..."
if systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-service=http
  firewall-cmd --permanent --add-service=https
  firewall-cmd --reload
fi

# ── Enable and start services ──────────────────────────────────────────────────
echo "==> Enabling services..."
systemctl enable --now php-fpm
systemctl enable --now httpd

echo "==> Apache + WordPress bootstrap complete."
