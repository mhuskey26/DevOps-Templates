terraform {
  backend "gcs" {
    bucket = "your-project-id-tfstate"
    prefix = "07-managing-multiple-environments/staging"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "your-project-id"
  region  = "us-east1"
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
  project_id      = "your-project-id"
  bucket_prefix   = "webapp-${local.environment_name}"
  domain          = "devopsdeployed.com"
  environment_name = local.environment_name
  machine_type    = "e2-micro"
  create_dns_zone = false
  db_name         = "${local.environment_name}mydb"
  db_user         = "webapp_user"
  db_pass         = var.db_pass
}
