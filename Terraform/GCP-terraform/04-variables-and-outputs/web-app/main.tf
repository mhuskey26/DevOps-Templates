terraform {
  backend "gcs" {
    bucket = "your-project-id-tfstate"
    prefix = "04-variables-and-outputs/web-app"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# VPC Network
resource "google_compute_network" "webapp" {
  name                    = "webapp-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "webapp" {
  name          = "webapp-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.webapp.id
}

# Firewall Rules
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http-8080"
  network = google_compute_network.webapp.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_compute_firewall" "allow_health_check" {
  name    = "allow-health-check"
  network = google_compute_network.webapp.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["web"]
}

# Compute Instances
resource "google_compute_instance" "instance_1" {
  name         = "webapp-instance-1"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network    = google_compute_network.webapp.name
    subnetwork = google_compute_subnetwork.webapp.name
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "Hello, World 1" > index.html
    nohup python3 -m http.server 8080 &
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "instance_2" {
  name         = "webapp-instance-2"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network    = google_compute_network.webapp.name
    subnetwork = google_compute_subnetwork.webapp.name
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "Hello, World 2" > index.html
    nohup python3 -m http.server 8080 &
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }
}

# Cloud Storage Bucket
resource "google_storage_bucket" "webapp_data" {
  name          = "${var.bucket_prefix}-${random_string.bucket_suffix.result}"
  location      = "US"
  force_destroy = true

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Instance Group
resource "google_compute_instance_group" "webservers" {
  name        = "webapp-instance-group"
  description = "Web server instance group"
  zone        = var.zone

  instances = [
    google_compute_instance.instance_1.id,
    google_compute_instance.instance_2.id,
  ]

  named_port {
    name = "http"
    port = 8080
  }
}

# Health Check
resource "google_compute_health_check" "webapp" {
  name               = "webapp-health-check"
  check_interval_sec = 15
  timeout_sec        = 3

  http_health_check {
    port         = 8080
    request_path = "/"
  }
}

# Backend Service
resource "google_compute_backend_service" "webapp" {
  name          = "webapp-backend"
  health_checks = [google_compute_health_check.webapp.id]
  port_name     = "http"
  protocol      = "HTTP"
  timeout_sec   = 30

  backend {
    group = google_compute_instance_group.webservers.id
  }
}

# URL Map
resource "google_compute_url_map" "webapp" {
  name            = "webapp-url-map"
  default_service = google_compute_backend_service.webapp.id
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "webapp" {
  name    = "webapp-http-proxy"
  url_map = google_compute_url_map.webapp.id
}

# Global Forwarding Rule (Load Balancer)
resource "google_compute_global_address" "webapp" {
  name = "webapp-lb-ip"
}

resource "google_compute_global_forwarding_rule" "webapp" {
  name       = "webapp-forwarding-rule"
  target     = google_compute_target_http_proxy.webapp.id
  port_range = "80"
  ip_address = google_compute_global_address.webapp.address
}

# Cloud DNS
resource "google_dns_managed_zone" "primary" {
  name        = "devopsdeployed-zone"
  dns_name    = "${var.domain}."
  description = "Primary DNS zone"
}

resource "google_dns_record_set" "root" {
  name         = google_dns_managed_zone.primary.dns_name
  managed_zone = google_dns_managed_zone.primary.name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.webapp.address]
}

# Cloud SQL Instance
resource "google_sql_database_instance" "webapp" {
  name             = "webapp-db-${random_string.bucket_suffix.result}"
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

resource "google_sql_database" "webapp" {
  name     = var.db_name
  instance = google_sql_database_instance.webapp.name
}

resource "google_sql_user" "webapp" {
  name     = var.db_user
  instance = google_sql_database_instance.webapp.name
  password = var.db_pass
}
