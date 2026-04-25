#!/bin/bash

# Amazon Linux 2023 EC2 bootstrap for WordPress behind ALB + ASG.
# Storage model:
# - WordPress core code is local on each EC2 instance.
# - Shared mutable WordPress content is stored on EFS.
# - Database is external, such as RDS or Aurora MySQL.

set -euo pipefail

exec > >(tee /var/log/wordpress-bootstrap.log | logger -t wordpress-bootstrap -s 2>/dev/console) 2>&1

EFS_DNS_NAME="fs-xxxxxxxx.efs.us-west-1.amazonaws.com"
SITE_DOMAIN="example.com"
WEB_ROOT="/var/www/html"
EFS_MOUNT_POINT="/mnt/efs"
SHARED_WP_CONTENT="$EFS_MOUNT_POINT/wp-content"
WP_DB_NAME="wordpress"
WP_DB_USER="wp_user"
WP_DB_PASSWORD="change-me"
WP_DB_HOST="wordpress.cluster-xxxxxxxx.us-west-1.rds.amazonaws.com"

if [ "$EFS_DNS_NAME" = "fs-xxxxxxxx.efs.us-west-1.amazonaws.com" ]; then
	echo "Update EFS_DNS_NAME before using this as EC2 user data."
	exit 1
fi

dnf update -y
dnf install -y \
	httpd \
	mod_ssl \
	curl \
	tar \
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

mkdir -p "$WEB_ROOT"
mkdir -p "$EFS_MOUNT_POINT"

if ! grep -q "$EFS_DNS_NAME:/ $EFS_MOUNT_POINT efs" /etc/fstab; then
	echo "$EFS_DNS_NAME:/ $EFS_MOUNT_POINT efs _netdev,tls 0 0" >> /etc/fstab
fi

mount -a
mkdir -p "$SHARED_WP_CONTENT/uploads"
mkdir -p "$SHARED_WP_CONTENT/plugins"
mkdir -p "$SHARED_WP_CONTENT/themes"

if [ ! -f "$WEB_ROOT/wp-load.php" ]; then
	curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz
	tar -xzf /tmp/wordpress.tar.gz -C /tmp
	cp -a /tmp/wordpress/. "$WEB_ROOT"/
fi

if [ -d "$WEB_ROOT/wp-content" ] && [ ! -L "$WEB_ROOT/wp-content" ] && [ -z "$(ls -A "$SHARED_WP_CONTENT")" ]; then
	cp -a "$WEB_ROOT/wp-content"/. "$SHARED_WP_CONTENT"/
fi

rm -rf "$WEB_ROOT/wp-content"
ln -s "$SHARED_WP_CONTENT" "$WEB_ROOT/wp-content"

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
    ErrorLog /var/log/httpd/wordpress-error.log
    CustomLog /var/log/httpd/wordpress-access.log combined
</VirtualHost>
EOF

if [ ! -f "$WEB_ROOT/wp-config.php" ]; then
	SALTS="$(curl -fsSL https://api.wordpress.org/secret-key/1.1/salt/ || true)"
	cat > "$WEB_ROOT/wp-config.php" <<EOF
<?php
define( 'DB_NAME', '${WP_DB_NAME}' );
define( 'DB_USER', '${WP_DB_USER}' );
define( 'DB_PASSWORD', '${WP_DB_PASSWORD}' );
define( 'DB_HOST', '${WP_DB_HOST}' );
define( 'DB_CHARSET', 'utf8mb4' );
define( 'DB_COLLATE', '' );

${SALTS}








\$table_prefix = 'wp_';

define( 'WP_HOME', 'https://${SITE_DOMAIN}' );
define( 'WP_SITEURL', 'https://${SITE_DOMAIN}' );
define( 'FS_METHOD', 'direct' );
define( 'DISABLE_WP_CRON', true );

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF
fi

cat > "$WEB_ROOT/healthcheck.php" <<'EOF'
<?php
http_response_code(200);
echo 'ok';
EOF

usermod -a -G apache ec2-user || true
chown -R apache:apache /var/www "$EFS_MOUNT_POINT"
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;
chown -h apache:apache "$WEB_ROOT/wp-content"

systemctl enable php-fpm
systemctl enable httpd
systemctl restart php-fpm
systemctl restart httpd

echo "Bootstrap complete. Validate EFS with: df -h | grep $EFS_MOUNT_POINT"
echo "Validate wp-content link with: ls -ld $WEB_ROOT/wp-content"

