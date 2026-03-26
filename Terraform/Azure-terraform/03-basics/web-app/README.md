# Web Application Infrastructure

This Terraform configuration deploys a complete web application infrastructure on Azure including:

- Azure Virtual Machines (2 instances)
- Azure Application Gateway (Load Balancer)
- Azure Storage Account with blob versioning
- Azure PostgreSQL Database
- Azure DNS configuration
- Virtual Network with subnets
- Network Security Groups

## Prerequisites

- Azure CLI installed and configured (`az login`)
- Terraform installed
- SSH key pair at `~/.ssh/id_rsa.pub`
- Azure Storage backend set up (see `/code/03-basics/azure-backend`)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- The PostgreSQL password should be changed and stored securely (e.g., Azure Key Vault)
- The Application Gateway uses Standard_v2 SKU which may incur higher costs
- SSH key path assumes default location (`~/.ssh/id_rsa.pub`)
