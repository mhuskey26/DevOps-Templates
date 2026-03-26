terraform {
  backend "gcs" {
    bucket = "your-project-id-tfstate"
    prefix = "04-variables-and-outputs/examples"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  extra_tag = "extra-tag"
}

resource "google_compute_network" "main" {
  name                    = "example-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "example-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.main.id
}

resource "google_compute_instance" "vm" {
  name         = "example-vm"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.main.name
  }

  labels = {
    name      = "example-vm"
    extra_tag = local.extra_tag
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_sql_database_instance" "db_instance" {
  name             = "example-db-${random_string.suffix.result}"
  database_version = "POSTGRES_12"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    backup_configuration {
      enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "database" {
  name     = "mydb"
  instance = google_sql_database_instance.db_instance.name
}

resource "google_sql_user" "user" {
  name     = var.db_user
  instance = google_sql_database_instance.db_instance.name
  password = var.db_pass
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
