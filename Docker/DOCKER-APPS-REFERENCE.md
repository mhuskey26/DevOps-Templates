# Docker Application Images - Quick Reference

## Available Configurations

### 1. WordPress
**Location**: `Docker/WordPress/`
**Port**: 8080 (WordPress), 8081 (phpMyAdmin)
**Stack**: WordPress + MySQL 8.0 + phpMyAdmin
**Start**: `docker-compose up -d`

### 2. PHP Web App
**Location**: `Docker/PHP-WebApp/`
**Port**: 8082 (PHP App), 8083 (phpMyAdmin)
**Stack**: PHP 8.2-FPM + Nginx + MySQL 8.0 + Supervisor
**Start**: `docker-compose up -d`

### 3. .NET 8 Application
**Location**: `Docker/DotNet-App/`
**Port**: 8084 (.NET App), 8085 (pgAdmin) or 8084 + 1433 (SQL Server)
**Stack Options**: 
- .NET 8 + PostgreSQL 16 + pgAdmin
- .NET 8 + SQL Server 2022
**Start**: 
- PostgreSQL: `docker-compose up -d`
- SQL Server: `docker-compose -f docker-compose.sqlserver.yml up -d`

## Port Summary
- 8080: WordPress
- 8081: WordPress phpMyAdmin
- 8082: PHP Web App
- 8083: PHP App phpMyAdmin
- 8084: .NET Application
- 8085: pgAdmin (PostgreSQL)
- 1433: SQL Server
- 3306: MySQL (PHP App)
- 5432: PostgreSQL

## Quick Commands

### Start All Applications
```bash
cd Docker/WordPress && docker-compose up -d
cd ../PHP-WebApp && docker-compose up -d
cd ../DotNet-App && docker-compose up -d
```

### Stop All Applications
```bash
cd Docker/WordPress && docker-compose down
cd ../PHP-WebApp && docker-compose down
cd ../DotNet-App && docker-compose down
```

### Check Status
```bash
docker ps
```

### View Logs
```bash
docker-compose logs -f [service-name]
```

## Image Sizes (Approximate)
- WordPress: ~600MB
- PHP-FPM Alpine: ~150MB
- .NET Alpine: ~200MB (runtime only)
- .NET Full: ~400MB (runtime only)
- MySQL 8.0: ~500MB
- PostgreSQL 16: ~300MB

## Security Notes
**ALL DEFAULT PASSWORDS MUST BE CHANGED IN PRODUCTION!**

See individual README files for:
- Production security checklist
- SSL/TLS configuration
- Backup procedures
- Performance tuning
- Troubleshooting guides
