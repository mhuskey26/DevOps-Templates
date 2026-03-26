# should specify optional vs required

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "GCP zone for resources"
  type        = string
  default     = "us-east1-b"
}

variable "machine_type" {
  description = "Machine type for compute instance"
  type        = string
  default     = "e2-micro"
}

variable "db_user" {
  description = "username for database"
  type        = string
  default     = "dbadmin"
}

variable "db_pass" {
  description = "password for database"
  type        = string
  sensitive   = true
}
