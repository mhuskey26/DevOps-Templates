terraform {
  # Assumes storage account and container already set up
  # See /code/03-basics/azure-backend
  backend "azurerm" {
    resource_group_name  = "terraform-backend-rg"
    storage_account_name = "tfstatedevops"
    container_name       = "tfstate"
    key                  = "07-managing-multiple-environments/global/terraform.tfstate"
  }

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

resource "azurerm_resource_group" "global" {
  name     = "global-resources-rg"
  location = "East US"
}

# DNS zone is shared across staging and production
resource "azurerm_dns_zone" "primary" {
  name                = "devopsdeployed.com"
  resource_group_name = azurerm_resource_group.global.name
}
