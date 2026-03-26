# WordPress Docker Setup

Complete Docker environment for hosting WordPress sites with MySQL and phpMyAdmin.

## Features
- WordPress (latest version)
- MySQL 8.0 database
- phpMyAdmin for database management
- WP-CLI installed
- Optimized PHP settings for WordPress
- Persistent data volumes

## Quick Start

### Using Docker Compose (Recommended)
```bash
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f wordpress

# Stop services
docker-compose down

# Stop and remove volumes (WARNING: deletes data)
docker-compose down -v
```

### Using Custom Dockerfile
```bash
# Build custom image
docker build -t custom-wordpress .

# Run with Docker Compose using custom image
# (Modify docker-compose.yml to use 'build: .' instead of 'image: wordpress:latest')
docker-compose up -d
```

## Access Points
- **WordPress Site**: http://localhost:8080
- **phpMyAdmin**: http://localhost:8081

## Configuration

### Database Credentials
- Database: `wordpress`
- User: `wordpress`
- Password: `wordpress_password`
- Root Password: `root_password`

**IMPORTANT**: Change these in production!

### Environment Variables
Edit `docker-compose.yml` to customize:
- `WORDPRESS_DB_HOST`: Database host
- `WORDPRESS_DB_USER`: Database user
- `WORDPRESS_DB_PASSWORD`: Database password
- `WORDPRESS_DB_NAME`: Database name

### PHP Settings
Custom PHP configuration in Dockerfile:
- Upload max filesize: 64MB
- Post max size: 64MB
- Max execution time: 300s
- Memory limit: 256MB

## Volumes
- `wordpress_data`: WordPress files
- `db_data`: MySQL database
- `./wp-content`: WordPress content (themes, plugins, uploads)

## WP-CLI Usage
```bash
# Access WP-CLI in container
docker exec -it wordpress wp --info

# Install plugin
docker exec -it wordpress wp plugin install contact-form-7 --activate --allow-root

# Update WordPress
docker exec -it wordpress wp core update --allow-root

# Create admin user
docker exec -it wordpress wp user create newadmin admin@example.com --role=administrator --allow-root
```

## Backup and Restore

### Backup
```bash
# Backup database
docker exec wordpress_db mysqldump -u wordpress -pwordpress_password wordpress > backup.sql

# Backup WordPress files
docker cp wordpress:/var/www/html ./wordpress-backup
```

### Restore
```bash
# Restore database
docker exec -i wordpress_db mysql -u wordpress -pwordpress_password wordpress < backup.sql

# Restore files
docker cp ./wordpress-backup/. wordpress:/var/www/html
```

## Production Considerations
1. Change all default passwords
2. Use environment variables file (.env)
3. Configure SSL/TLS (use reverse proxy like Nginx)
4. Set up automated backups
5. Configure proper file permissions
6. Enable WordPress security plugins
7. Use specific version tags instead of 'latest'
8. Implement monitoring and logging
