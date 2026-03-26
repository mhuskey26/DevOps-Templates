# VPC Network
resource "google_compute_network" "webapp" {
  name                    = "${var.app_name}-${var.environment_name}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "webapp" {
  name          = "${var.app_name}-${var.environment_name}-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.webapp.id
}

# Firewall Rules
resource "google_compute_firewall" "allow_http" {
  name    = "${var.app_name}-${var.environment_name}-allow-http"
  network = google_compute_network.webapp.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.app_name}-${var.environment_name}-web"]
}

resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.app_name}-${var.environment_name}-allow-health-check"
  network = google_compute_network.webapp.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["${var.app_name}-${var.environment_name}-web"]
}

# Instance Group
resource "google_compute_instance_group" "webservers" {
  name        = "${var.app_name}-${var.environment_name}-instance-group"
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
  name               = "${var.app_name}-${var.environment_name}-health-check"
  check_interval_sec = 15
  timeout_sec        = 3

  http_health_check {
    port         = 8080
    request_path = "/"
  }
}

# Backend Service
resource "google_compute_backend_service" "webapp" {
  name          = "${var.app_name}-${var.environment_name}-backend"
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
  name            = "${var.app_name}-${var.environment_name}-url-map"
  default_service = google_compute_backend_service.webapp.id
}

# HTTP Proxy
resource "google_compute_target_http_proxy" "webapp" {
  name    = "${var.app_name}-${var.environment_name}-http-proxy"
  url_map = google_compute_url_map.webapp.id
}

# Global Forwarding Rule (Load Balancer)
resource "google_compute_global_address" "webapp" {
  name = "${var.app_name}-${var.environment_name}-lb-ip"
}

resource "google_compute_global_forwarding_rule" "webapp" {
  name       = "${var.app_name}-${var.environment_name}-forwarding-rule"
  target     = google_compute_target_http_proxy.webapp.id
  port_range = "80"
  ip_address = google_compute_global_address.webapp.address
}
