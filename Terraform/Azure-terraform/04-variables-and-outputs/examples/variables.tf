# should specify optional vs required

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "db_user" {
  description = "username for database"
  type        = string
  default     = "psqladmin"
}

variable "db_pass" {
  description = "password for database"
  type        = string
  sensitive   = true
}
