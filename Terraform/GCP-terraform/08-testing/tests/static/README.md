## Static Testing

Static testing validates Terraform code without deploying infrastructure:

```bash
# Validate syntax
terraform validate

# Check formatting
terraform fmt -check

# Lint with tflint
tflint

# Security scanning with terrascan
terrascan scan
```

These tests are fast and catch basic errors early in the development process.
