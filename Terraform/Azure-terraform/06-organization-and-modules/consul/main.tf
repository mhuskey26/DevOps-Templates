# Example: Using modules from Terraform Registry
# Azure doesn't have a direct Consul module equivalent
# This shows the pattern for using Azure modules from the registry

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Example of using an Azure module from the registry
# module "network" {
#   source              = "Azure/network/azurerm"
#   version            = "~> 5.0"
#   resource_group_name = "module-example-rg"
#   location           = "East US"
# }

resource "azurerm_resource_group" "example" {
  name     = "consul-example-rg"
  location = "East US"
}
