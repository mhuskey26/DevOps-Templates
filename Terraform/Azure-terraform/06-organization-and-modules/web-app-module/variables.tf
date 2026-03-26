# General Variables

variable "location" {
  description = "Default Azure region for resources"
  type        = string
  default     = "East US"
}

variable "app_name" {
  description = "Name of the web application"
  type        = string
  default     = "web-app"
}

variable "environment_name" {
  description = "Deployment environment (dev/staging/production)"
  type        = string
  default     = "dev"
}

# VM Variables

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

# Storage Variables

variable "storage_account_prefix" {
  description = "prefix of storage account for app data"
  type        = string
}

# DNS Variables

variable "create_dns_zone" {
  description = "If true, create new DNS zone, if false read existing DNS zone"
  type        = bool
  default     = false
}

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
