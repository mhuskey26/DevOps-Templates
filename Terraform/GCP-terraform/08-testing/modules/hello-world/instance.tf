resource "google_compute_network" "main" {
  name                    = "hello-world-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  name          = "hello-world-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east1"
  network       = google_compute_network.main.id
}

resource "google_compute_firewall" "allow_http" {
  name    = "hello-world-allow-http"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}

resource "google_compute_address" "main" {
  name = "hello-world-ip"
}

resource "google_compute_instance" "instance" {
  name         = "hello-world-vm"
  machine_type = "e2-micro"
  zone         = "us-east1-b"

  tags = ["web"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network    = google_compute_network.main.name
    subnetwork = google_compute_subnetwork.main.name
    access_config {
      nat_ip = google_compute_address.main.address
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    echo "Hello, World" > index.html
    nohup python3 -m http.server 8080 &
  EOF

  service_account {
    scopes = ["cloud-platform"]
  }
}

output "instance_ip_addr" {
  value = google_compute_address.main.address
}
