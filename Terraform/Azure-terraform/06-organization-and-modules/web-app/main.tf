terraform {
  # Assumes storage account and container already set up
  # See /code/03-basics/azure-backend
  backend "azurerm" {
    resource_group_name  = "terraform-backend-rg"
    storage_account_name = "tfstatedevops"
    container_name       = "tfstate"
    key                  = "06-organization-and-modules/web-app/terraform.tfstate"
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

variable "db_pass_1" {
  description = "password for database #1"
  type        = string
  sensitive   = true
}

variable "db_pass_2" {
  description = "password for database #2"
  type        = string
  sensitive   = true
}

module "web_app_1" {
  source = "../web-app-module"

  # Input Variables
  storage_account_prefix = "webapp1data"
  domain                 = "devopsdeployed.com"
  app_name               = "web-app-1"
  environment_name       = "production"
  vm_size                = "Standard_B1s"
  create_dns_zone        = true
  db_name                = "webapp1db"
  db_user                = "psqladmin"
  db_pass                = var.db_pass_1
}

module "web_app_2" {
  source = "../web-app-module"

  # Input Variables
  storage_account_prefix = "webapp2data"
  domain                 = "anotherdevopsdeployed.com"
  app_name               = "web-app-2"
  environment_name       = "production"
  vm_size                = "Standard_B1s"
  create_dns_zone        = true
  db_name                = "webapp2db"
  db_user                = "psqladmin"
  db_pass                = var.db_pass_2
}
