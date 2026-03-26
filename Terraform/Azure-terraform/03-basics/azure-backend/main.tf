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

resource "azurerm_resource_group" "backend" {
  name     = "terraform-backend-rg"
  location = "East US"
}

resource "azurerm_storage_account" "backend" {
  name                     = "tfstatedevops"
  resource_group_name      = azurerm_resource_group.backend.name
  location                 = azurerm_resource_group.backend.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

  tags = {
    environment = "terraform-backend"
  }
}

resource "azurerm_storage_container" "backend" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.backend.name
  container_access_type = "private"
}

# Uncomment after initial apply to migrate state to remote backend
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-backend-rg"
#     storage_account_name = "tfstatedevops"
#     container_name       = "tfstate"
#     key                  = "terraform.tfstate"
#   }
# }
