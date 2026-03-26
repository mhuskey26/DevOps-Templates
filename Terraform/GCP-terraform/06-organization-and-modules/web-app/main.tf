terraform {
  backend "gcs" {
    bucket = "your-project-id-tfstate"
    prefix = "06-organization-and-modules/web-app"
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
  project_id      = "your-project-id"
  bucket_prefix   = "webapp1data"
  domain          = "devopsdeployed.com"
  app_name        = "web-app-1"
  environment_name = "production"
  machine_type    = "e2-micro"
  create_dns_zone = true
  db_name         = "webapp1db"
  db_user         = "webapp1user"
  db_pass         = var.db_pass_1
}

module "web_app_2" {
  source = "../web-app-module"

  # Input Variables
  project_id      = "your-project-id"
  bucket_prefix   = "webapp2data"
  domain          = "anotherdevopsdeployed.com"
  app_name        = "web-app-2"
  environment_name = "production"
  machine_type    = "e2-micro"
  create_dns_zone = true
  db_name         = "webapp2db"
  db_user         = "webapp2user"
  db_pass         = var.db_pass_2
}
