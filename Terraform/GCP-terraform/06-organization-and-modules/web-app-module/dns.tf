resource "google_dns_managed_zone" "primary" {
  count       = var.create_dns_zone ? 1 : 0
  name        = "${var.app_name}-${var.environment_name}-zone"
  dns_name    = "${var.domain}."
  description = "DNS zone for ${var.app_name}"
}

data "google_dns_managed_zone" "primary" {
  count = var.create_dns_zone ? 0 : 1
  name  = "${var.app_name}-primary-zone"
}

locals {
  dns_zone_name = var.create_dns_zone ? google_dns_managed_zone.primary[0].name : data.google_dns_managed_zone.primary[0].name
  subdomain     = var.environment_name == "production" ? "" : "${var.environment_name}."
}

resource "google_dns_record_set" "root" {
  name         = "${local.subdomain}${var.domain}."
  managed_zone = local.dns_zone_name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.webapp.address]
}
