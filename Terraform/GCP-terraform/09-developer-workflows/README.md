# 09 - Developer Workflows

## Local Development

### Prerequisites
- GCP account and project
- gcloud CLI installed and configured
- Terraform installed
- Code editor with Terraform extension (VS Code recommended)

### Development Workflow

1. **Authenticate with GCP**
   ```bash
   gcloud auth application-default login
   # Or set service account credentials
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/sa-key.json"
   ```

2. **Plan changes locally**
   ```bash
   terraform init
   terraform plan
   ```

3. **Apply changes to development environment**
   ```bash
   terraform apply
   ```

4. **Test changes**
   - Manual testing
   - Automated tests

5. **Commit and push**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push
   ```

## CI/CD Integration

### GitHub Actions
See `.github/workflows/terraform.yml` for example

### Cloud Build
GCP's native CI/CD service can run Terraform:
```yaml
steps:
- name: 'hashicorp/terraform'
  args: ['init']
- name: 'hashicorp/terraform'
  args: ['plan']
- name: 'hashicorp/terraform'
  args: ['apply', '-auto-approve']
```

### Key Practices:
- Store secrets in Secret Manager
- Use service accounts for authentication
- Run `terraform plan` on pull requests
- Run `terraform apply` only on protected branches
- Implement approval gates for production

## State Management

### Remote State
- Use Cloud Storage for state backend
- Enable versioning on bucket
- State locking is automatic with GCS backend

### State File Security
- Never commit state files to git
- Use IAM to restrict bucket access
- Enable uniform bucket-level access
- Consider using separate projects per environment

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
- Use labels for resource organization
- Enable required APIs programmatically

## GCP-Specific Considerations

### API Enablement
Always enable required APIs:
```hcl
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}
```

### Service Accounts
Use least-privilege service accounts:
```hcl
resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform Service Account"
}
```

### Resource Quotas
Be aware of GCP quotas and request increases as needed.

### Cost Management
- Use budgets and alerts
- Tag resources with labels
- Use preemptible VMs for dev/test
- Review and clean up unused resources
