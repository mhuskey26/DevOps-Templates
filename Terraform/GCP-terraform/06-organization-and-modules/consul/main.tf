# Example: Using modules from Terraform Registry
# GCP has many official and community modules available

terraform {
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

# Example of using a GCP module from the registry
# module "vpc" {
#   source  = "terraform-google-modules/network/google"
#   version = "~> 6.0"
#   
#   project_id   = "your-project-id"
#   network_name = "example-vpc"
#   subnets = [
#     {
#       subnet_name   = "subnet-01"
#       subnet_ip     = "10.10.10.0/24"
#       subnet_region = "us-east1"
#     }
#   ]
# }

resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
  project = "your-project-id"
}
