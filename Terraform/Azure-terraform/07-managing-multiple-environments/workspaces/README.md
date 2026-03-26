Warning about manually switching environments
```bash
terraform workspace new production
terraform workspace list
terraform workspace select staging
```

## Workspaces Approach

Using Terraform workspaces to manage multiple environments from a single configuration:

### Benefits:
- Single configuration to maintain
- Easy to switch between environments
- Less code duplication

### Considerations:
- Easy to accidentally apply to wrong workspace
- Shared state file structure
- Not recommended for production use by HashiCorp
- Better suited for development/testing scenarios
