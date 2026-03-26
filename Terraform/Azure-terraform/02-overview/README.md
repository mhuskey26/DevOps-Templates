## 02 - Overview + Setup

## Install Terraform

Official installation instructions from HashiCorp: https://learn.hashicorp.com/tutorials/terraform/install-cli

## Azure Account Setup

Azure Terraform provider documentation: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure

1) Create a Service Principal in Azure Active Directory
2) Assign the necessary roles (e.g. Contributor)
3) Save the following credentials:
   - ARM_CLIENT_ID (Application/Client ID)
   - ARM_CLIENT_SECRET (Client Secret)
   - ARM_SUBSCRIPTION_ID (Subscription ID)
   - ARM_TENANT_ID (Tenant ID)

Alternative: Use Azure CLI authentication with `az login` -- https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

## Hello World

`./main.tf` contains minimal configuration to provision an Azure Virtual Machine.

1) `az login` (or set environment variables for service principal)
2) `terraform init`
3) `terraform plan`
4) `terraform apply`
