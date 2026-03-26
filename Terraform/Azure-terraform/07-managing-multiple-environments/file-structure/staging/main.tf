terraform {
  # Assumes storage account and container already set up
  # See /code/03-basics/azure-backend
  backend "azurerm" {
    resource_group_name  = "terraform-backend-rg"
    storage_account_name = "tfstatedevops"
    container_name       = "tfstate"
    key                  = "07-managing-multiple-environments/staging/terraform.tfstate"
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

variable "db_pass" {
  description = "password for database"
  type        = string
  sensitive   = true
}

locals {
  environment_name = "staging"
}

module "web_app" {
  source = "../../../06-organization-and-modules/web-app-module"

  # Input Variables
  storage_account_prefix = "webapp${local.environment_name}"
  domain                 = "devopsdeployed.com"
  environment_name       = local.environment_name
  vm_size                = "Standard_B1s"
  create_dns_zone        = false
  db_name                = "${local.environment_name}mydb"
  db_user                = "psqladmin"
  db_pass                = var.db_pass
}
