# 09 - Developer Workflows

## Local Development

### Prerequisites
- Azure CLI installed and configured
- Terraform installed
- Code editor with Terraform extension (VS Code recommended)

### Development Workflow

1. **Plan changes locally**
   ```bash
   az login
   terraform init
   terraform plan
   ```

2. **Apply changes to development environment**
   ```bash
   terraform apply
   ```

3. **Test changes**
   - Manual testing
   - Automated tests

4. **Commit and push**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push
   ```

## CI/CD Integration

### GitHub Actions
See `.github/workflows/terraform.yml` for example

### Azure DevOps Pipelines
Azure DevOps provides native Terraform tasks:
- Terraform Installer
- Terraform Init
- Terraform Plan
- Terraform Apply

### Key Practices:
- Store secrets in Azure Key Vault or GitHub Secrets
- Use service principals for authentication
- Run `terraform plan` on pull requests
- Run `terraform apply` only on protected branches
- Implement approval gates for production

## State Management

### Remote State
- Use Azure Storage for state backend
- Enable state locking
- Encrypt state at rest

### State File Security
- Never commit state files to git
- Restrict access to state storage
- Enable versioning on storage container

## Code Organization

### Repository Structure
```
terraform/
├── modules/          # Reusable modules
├── environments/     # Environment-specific configs
│   ├── dev/
│   ├── staging/
│   └── production/
├── global/          # Shared resources
└── .github/         # CI/CD workflows
```

### Best Practices:
- Use consistent naming conventions
- Document module inputs/outputs
- Pin provider versions
- Use .terraformignore
- Regular `terraform fmt` and `terraform validate`
