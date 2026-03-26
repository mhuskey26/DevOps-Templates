# Compute Instances
resource "google_compute_instance" "instance_1" {
  name         = "${var.app_name}-${var.environment_name}-instance-1"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["${var.app_name}-${var.environment_name}-web"]

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
  name         = "${var.app_name}-${var.environment_name}-instance-2"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["${var.app_name}-${var.environment_name}-web"]

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
