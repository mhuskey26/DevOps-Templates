Automated tests go here!

## Testing Approaches

1. **Static Testing** - Validate syntax and configuration
   - `terraform validate`
   - `terraform fmt -check`
   - Linting tools (tflint, terrascan)

2. **Bash Testing** - Simple shell script tests
   - Deploy infrastructure
   - Test endpoints/functionality
   - Destroy infrastructure

3. **Terratest** - Go-based testing framework
   - More robust and maintainable
   - Better error handling
   - Retry logic and parallel execution
