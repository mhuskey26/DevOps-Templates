# General Variables

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Default GCP region for resources"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "Default GCP zone for resources"
  type        = string
  default     = "us-east1-b"
}

# Compute Variables

variable "machine_type" {
  description = "Machine type for compute instances"
  type        = string
  default     = "e2-micro"
}

# Storage Variables

variable "bucket_prefix" {
  description = "prefix of storage bucket for app data"
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
