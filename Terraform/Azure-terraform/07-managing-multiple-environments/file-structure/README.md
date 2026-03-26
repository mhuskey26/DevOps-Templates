- Note about using separate Azure subscriptions (avoids prefix issues, improved RBAC control)
  - Cover this in advanced section?
  
```hcl
provider "azurerm" {
  features {}
  subscription_id = "12345678-1234-1234-1234-123456789012"
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
