## 03 - Basics

## Remote Backends

Remote backends enable storage of TF state in a remote, location to enable secure collaboration.

### Terraform Cloud

https://www.terraform.io/cloud

`./terraform-cloud-backend/main.tf`

### Azure Storage Account

Steps to initialize backend in Azure and manage it with Terraform:

1) Use config from `./azure-backend/` (init, plan, apply) to provision storage account and container with local state
2) Uncomment the remote backend configuration
3) Reinitialize with `terraform init`:

```
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "azurerm" backend. No existing state was found in the newly
  configured "azurerm" backend. Do you want to copy this state to the new "azurerm"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes 
```

Now the Storage Account and container are managed and are able to be used as the state backend!

## Web-App

Generic web application architecture including:
- Azure Virtual Machines
- Azure Storage Account
- Azure SQL Database
- Application Gateway / Load Balancer
- Azure DNS config

This example will be refined and improved in later modules.

## Architecture
![](./web-app/architecture.png)
