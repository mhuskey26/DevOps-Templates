- Note about using separate GCP projects (improved IAM control, resource isolation)
  - Cover this in advanced section?
  
```hcl
provider "google" {
  project = "production-project-id"
  region  = "us-east1"
}
```

## File Structure Approach

Organizing Terraform configurations by environment using separate directories:

```
07-managing-multiple-environments/
├── file-structure/
│   ├── global/          # Shared resources (DNS zones, etc.)
│   ├── staging/         # Staging environment
│   └── production/      # Production environment
```

### Benefits:
- Clear separation of environments
- Different state files per environment
- Easier to manage permissions
- Reduced risk of accidental changes to production

### Considerations:
- Some code duplication
- Need to sync changes across environments
- More directories to manage
