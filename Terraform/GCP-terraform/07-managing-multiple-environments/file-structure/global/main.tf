terraform {
  backend "gcs" {
    bucket = "your-project-id-tfstate"
    prefix = "07-managing-multiple-environments/global"
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

# DNS zone is shared across staging and production
resource "google_dns_managed_zone" "primary" {
  name        = "devopsdeployed-zone"
  dns_name    = "devopsdeployed.com."
  description = "Primary DNS zone shared across environments"
}
