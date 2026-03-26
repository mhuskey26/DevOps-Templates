# .NET 8 Web Application Docker Setup

Production-ready Docker environment for .NET 7+ applications running on Linux with database support.

## Features
- .NET 8 SDK (Alpine-based for smaller images)
- Multi-stage build for optimized image size
- PostgreSQL or SQL Server database options
- Database management UI (pgAdmin/SQL Server)
- Non-root user for security
- Health checks configured
- Environment-based configuration

## Supported .NET Versions
- .NET 8 (recommended - LTS)
- .NET 7 (change image tags to `7.0`)

## Project Structure
```
DotNet-App/
├── Dockerfile              # Alpine-based build
├── Dockerfile.full         # Debian-based build (more compatible)
├── docker-compose.yml      # With PostgreSQL
├── docker-compose.sqlserver.yml  # With SQL Server
├── .dockerignore
├── .env.example
└── README.md
```

## Quick Start

### Option 1: PostgreSQL Database
```bash
# Build and start
docker-compose up -d

# View logs
docker-compose logs -f dotnet-app

# Access application
curl http://localhost:8084
```

### Option 2: SQL Server Database
```bash
# Build and start with SQL Server
docker-compose -f docker-compose.sqlserver.yml up -d

# View logs
docker-compose -f docker-compose.sqlserver.yml logs -f dotnet-app
```

## Access Points

### With PostgreSQL
- **.NET Application**: http://localhost:8084
- **pgAdmin**: http://localhost:8085
  - Email: admin@example.com
  - Password: admin_password
- **PostgreSQL**: localhost:5432

### With SQL Server
- **.NET Application**: http://localhost:8084
- **SQL Server**: localhost:1433
  - User: sa
  - Password: YourStrong!Passw0rd

## Building Your Application

### 1. Prepare Your .NET Project
```bash
# Place your .NET project in this directory
# Project structure should be:
# DotNet-App/
#   ├── YourAppName.csproj
#   ├── Program.cs
#   ├── Controllers/
#   └── ...
```

### 2. Update Dockerfile
```dockerfile
# Change this line to match your project name:
ENTRYPOINT ["dotnet", "YourActualAppName.dll"]
```

### 3. Configure Connection String
In your `appsettings.json`:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=postgres;Database=appdb;Username=appuser;Password=app_password"
  }
}
```

Or for SQL Server:
```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=sqlserver;Database=AppDB;User Id=sa;Password=YourStrong!Passw0rd;TrustServerCertificate=True"
  }
}
```

### 4. Add Health Endpoint
```csharp
// In Program.cs
app.MapHealthChecks("/health");
```

## Building the Docker Image

### Standard Build (Alpine)
```bash
# Build image
docker build -t my-dotnet-app:v1.0 .

# Run container
docker run -d -p 8084:8080 my-dotnet-app:v1.0
```

### Full Build (Debian) - For Compatibility
```bash
# Use if Alpine has compatibility issues
docker build -f Dockerfile.full -t my-dotnet-app:v1.0 .
```

## Configuration

### Environment Variables
```yaml
environment:
  - ASPNETCORE_ENVIRONMENT=Production  # Development, Staging, Production
  - ASPNETCORE_URLS=http://+:8080
  - ConnectionStrings__DefaultConnection=...
```

### Database Credentials
**PostgreSQL:**
- User: `appuser`
- Password: `app_password`
- Database: `appdb`

**SQL Server:**
- User: `sa`
- Password: `YourStrong!Passw0rd`
- Database: `AppDB`

**IMPORTANT**: Change these in production!

## Entity Framework Core Migrations

### Run Migrations in Container
```bash
# Access container
docker exec -it dotnet-webapp bash

# Apply migrations
dotnet ef database update

# Create migration (development)
dotnet ef migrations add InitialCreate
```

### Automatic Migrations on Startup
Add to `Program.cs`:
```csharp
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    db.Database.Migrate();
}
```

## Development Workflow

### Local Development
```bash
# Run with hot reload
dotnet watch run

# Or use Docker with volume mount (add to docker-compose.yml):
volumes:
  - ./:/app
```

### Debug in Container
```yaml
# Add to docker-compose.yml for debugging:
environment:
  - ASPNETCORE_ENVIRONMENT=Development
ports:
  - "8084:8080"
  - "5000:5000"  # Debug port
```

## Common Commands

### Application Management
```bash
# Rebuild after code changes
docker-compose up -d --build

# View real-time logs
docker-compose logs -f dotnet-app

# Restart application
docker-compose restart dotnet-app

# Stop all services
docker-compose down

# Stop and remove volumes
docker-compose down -v
```

### Database Operations
```bash
# PostgreSQL backup
docker exec dotnet_postgres pg_dump -U appuser appdb > backup.sql

# PostgreSQL restore
docker exec -i dotnet_postgres psql -U appuser appdb < backup.sql

# SQL Server backup
docker exec dotnet_sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd' -Q "BACKUP DATABASE AppDB TO DISK='/var/opt/mssql/backup/AppDB.bak'"
```

### Container Shell Access
```bash
# Access .NET container
docker exec -it dotnet-webapp sh

# Access PostgreSQL
docker exec -it dotnet_postgres psql -U appuser -d appdb

# Access SQL Server
docker exec -it dotnet_sqlserver /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong!Passw0rd'
```

## Deployment Strategies

### Single Container Deployment
```bash
# Build optimized image
docker build -t myapp:v1.0 .

# Tag for registry
docker tag myapp:v1.0 myregistry.azurecr.io/myapp:v1.0

# Push to registry
docker push myregistry.azurecr.io/myapp:v1.0

# Deploy
docker run -d \
  -p 80:8080 \
  -e ConnectionStrings__DefaultConnection="..." \
  myregistry.azurecr.io/myapp:v1.0
```

### Docker Compose Production
```bash
# Use production compose file
docker-compose -f docker-compose.prod.yml up -d
```

## Performance Optimization

### Multi-stage Build Benefits
- SDK image (>1GB) used only for building
- Runtime image (Alpine: ~200MB, Debian: ~400MB)
- Smaller attack surface

### Runtime Optimizations
```dockerfile
# Enable ReadyToRun (faster startup)
RUN dotnet publish -c Release -o /app/publish /p:PublishReadyToRun=true

# Enable tiered compilation
ENV DOTNET_TieredCompilation=1
```

### Database Connection Pooling
```csharp
// In Program.cs
builder.Services.AddDbContextPool<ApplicationDbContext>(options =>
    options.UseNpgsql(connectionString));
```

## Security Best Practices

1. **Non-root User**: Already configured in Dockerfile
2. **Secrets Management**: Use Docker secrets or Azure Key Vault
3. **Update Base Images**: Regularly update .NET SDK/runtime
4. **HTTPS**: Configure with reverse proxy (Nginx/Traefik)
5. **Environment Variables**: Never commit secrets
6. **Database Access**: Use strong passwords, limit network exposure
7. **Health Checks**: Monitor application health

## Troubleshooting

### Application Won't Start
```bash
# Check logs
docker-compose logs dotnet-app

# Common issues:
# - Wrong DLL name in ENTRYPOINT
# - Missing database connection
# - Port already in use
```

### Database Connection Failed
```bash
# Verify database is running
docker-compose ps

# Test connection
docker exec dotnet_postgres pg_isready -U appuser

# Check environment variables
docker exec dotnet-webapp env | grep ConnectionStrings
```

### Build Errors
```bash
# Clean and rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Alpine Compatibility Issues
Some NuGet packages may not work with Alpine. Use `Dockerfile.full` instead.

## Production Considerations

1. **Use specific version tags**: `mcr.microsoft.com/dotnet/aspnet:8.0.1-alpine`
2. **Implement logging**: Use Serilog, NLog, or built-in providers
3. **Monitor performance**: Application Insights, Prometheus
4. **Use HTTPS**: Configure with reverse proxy
5. **Backup databases**: Implement automated backup strategy
6. **Scale horizontally**: Use orchestration (Kubernetes, Docker Swarm)
7. **Resource limits**: Set memory/CPU limits in docker-compose.yml

## Additional Resources

- [.NET Docker Samples](https://github.com/dotnet/dotnet-docker/tree/main/samples)
- [ASP.NET Core Best Practices](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/best-practices)
- [Docker Security](https://docs.docker.com/engine/security/)
