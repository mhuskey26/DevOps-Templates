# General Variables

variable "location" {
  description = "Default Azure region for resources"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "webapp-rg"
}

# VM Variables

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B1s"
}

# Storage Variables

variable "storage_account_prefix" {
  description = "prefix of storage account for app data"
  type        = string
}

# DNS Variables

variable "domain" {
  description = "Domain for website"
  type        = string
}

# Database Variables

variable "db_name" {
  description = "Name of DB"
  type        = string
}

variable "db_user" {
  description = "Username for DB"
  type        = string
}

variable "db_pass" {
  description = "Password for DB"
  type        = string
  sensitive   = true
}
