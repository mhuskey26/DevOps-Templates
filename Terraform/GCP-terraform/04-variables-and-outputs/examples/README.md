## Examples

### Variables

Terraform supports several methods (in order of increasing precedence) to provide variable values:
1. Default value in `variables.tf`
2. Via file `terraform.tfvars` or matching `*.auto.tfvars`
3. Via `-var-file="custom.tfvars"` CLI arg
4. Environment variable matching pattern `TF_VAR_<variable name>`
5. Via `-var="<variable name>=<value>"` CLI arg

See `./variables.tf` for examples

### Outputs

Terraform outputs allow you to:
- Display useful information after `terraform apply`
- Pass data between modules
- Query with `terraform output <output_name>`

See `./outputs.tf` for examples
