# Uncomment and fill in values to enable remote state in Azure Blob Storage.
# Create the storage account and container manually before running terraform init.
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-tfstate"
#     storage_account_name = "satfstatedemo"
#     container_name       = "tfstate"
#     key                  = "hello-aks-demo/terraform.tfstate"
#   }
# }
