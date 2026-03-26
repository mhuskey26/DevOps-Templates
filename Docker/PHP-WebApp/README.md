# PHP Web Application Docker Setup

Production-ready Docker environment for PHP web applications with Nginx, PHP-FPM, and MySQL.

## Features
- PHP 8.2-FPM (Alpine Linux)
- Nginx web server
- MySQL 8.0 database
- phpMyAdmin for database management
- Supervisor for process management
- Composer for dependency management
- Common PHP extensions (PDO, GD, ZIP, etc.)
- Opcache enabled for performance
- Optimized Nginx configuration

## Project Structure
```
PHP-WebApp/
├── Dockerfile              # Multi-stage PHP build
├── docker-compose.yml      # Service orchestration
├── nginx.conf              # Nginx main configuration
├── site.conf               # Site-specific Nginx config
├── supervisord.conf        # Process supervisor config
├── src/                    # Your PHP application code
│   └── public/             # Web root (index.php here)
├── logs/                   # Nginx logs
└── README.md
```

## Quick Start

### 1. Prepare Your Application
```bash
# Create source directory
mkdir -p src/public

# Create a sample index.php
cat > src/public/index.php << 'EOF'
<?php
phpinfo();
EOF
```

### 2. Start Services
```bash
# Build and start all services
docker-compose up -d

# View logs
docker-compose logs -f php-app

# Check status
docker-compose ps
```

### 3. Access Your Application
- **PHP Application**: http://localhost:8082
- **phpMyAdmin**: http://localhost:8083
- **MySQL**: localhost:3306

## Configuration

### Database Credentials
- Host: `mysql`
- Database: `webapp`
- User: `webapp_user`
- Password: `webapp_password`
- Root Password: `root_password`

### Environment Variables
Edit `docker-compose.yml` to customize:
```yaml
environment:
  - PHP_ENV=production
  - DB_HOST=mysql
  - DB_NAME=webapp
  - DB_USER=webapp_user
  - DB_PASSWORD=webapp_password
```

### PHP Settings
Current configuration (modify in Dockerfile):
- Upload max: 50MB
- Memory limit: 256MB
- Max execution time: 300s
- Opcache: Enabled

### Nginx Configuration
- Document root: `/var/www/html/public`
- PHP-FPM via Unix socket
- Gzip compression enabled
- Security headers configured
- Static file caching (30 days)

## Development vs Production

### Development Mode
```yaml
# In docker-compose.yml, add:
volumes:
  - ./src:/var/www/html

# This allows live code changes without rebuilding
```

### Production Mode
```bash
# Build with application code baked in
docker build -t my-php-app:v1.0 .

# Run without volume mounts
docker run -d -p 8082:80 my-php-app:v1.0
```

## Using Composer

### Install Dependencies in Container
```bash
# Access container
docker exec -it php-webapp sh

# Install dependencies
composer install

# Add package
composer require monolog/monolog

# Update dependencies
composer update
```

### During Build
Place `composer.json` in project root. Dependencies install automatically during image build.

## Common Tasks

### View Logs
```bash
# Application logs
docker-compose logs -f php-app

# Nginx access logs
docker exec php-webapp tail -f /var/log/nginx/access.log

# PHP error logs
docker exec php-webapp tail -f /var/log/php_errors.log
```

### Database Operations
```bash
# Connect to MySQL
docker exec -it php_mysql mysql -u webapp_user -pwebapp_password webapp

# Backup database
docker exec php_mysql mysqldump -u webapp_user -pwebapp_password webapp > backup.sql

# Restore database
docker exec -i php_mysql mysql -u webapp_user -pwebapp_password webapp < backup.sql
```

### Restart Services
```bash
# Restart PHP-FPM and Nginx
docker exec php-webapp supervisorctl restart all

# Restart all containers
docker-compose restart

# Rebuild after code changes
docker-compose up -d --build
```

## Frameworks Support

### Laravel
```nginx
# site.conf already configured for Laravel
# Just place Laravel in src/ directory
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

### Symfony
```nginx
# Modify site.conf for Symfony:
root /var/www/html/public;
location / {
    try_files $uri /index.php$is_args$args;
}
```

### CodeIgniter/Custom Framework
Adjust document root in `site.conf` as needed.

## Performance Tuning

### PHP Opcache (Already Enabled)
```ini
opcache.enable=1
opcache.memory_consumption=128
opcache.max_accelerated_files=4000
```

### Nginx Caching
Already configured for static assets (30-day cache).

### MySQL Optimization
```yaml
# Add to mysql service in docker-compose.yml:
command: --default-authentication-plugin=mysql_native_password --max_connections=200
```

## Security Considerations

1. **Change Default Passwords** (production)
2. **Use .env files** for sensitive data
3. **Enable HTTPS** (use reverse proxy)
4. **Restrict MySQL access** (remove port exposure in production)
5. **Update PHP/Nginx** regularly
6. **Disable phpMyAdmin** in production
7. **Use specific version tags** instead of 'latest'

## Troubleshooting

### PHP-FPM Not Responding
```bash
docker exec php-webapp supervisorctl status
docker exec php-webapp supervisorctl restart php-fpm
```

### Permission Issues
```bash
docker exec php-webapp chown -R nginx:nginx /var/www/html
docker exec php-webapp chmod -R 755 /var/www/html
```

### Nginx 502 Bad Gateway
Check PHP-FPM socket connection in site.conf and PHP-FPM configuration.

### Database Connection Failed
Verify environment variables and ensure MySQL container is running.
