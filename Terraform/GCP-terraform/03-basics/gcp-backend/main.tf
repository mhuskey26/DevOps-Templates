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

resource "google_storage_bucket" "terraform_state" {
  name          = "your-project-id-tfstate"
  location      = "US"
  force_destroy = false

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }
}

# Uncomment after initial apply to migrate state to remote backend
# terraform {
#   backend "gcs" {
#     bucket = "your-project-id-tfstate"
#     prefix = "terraform/state"
#   }
# }
