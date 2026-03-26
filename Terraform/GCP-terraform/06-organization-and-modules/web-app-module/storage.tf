resource "google_storage_bucket" "webapp" {
  name          = "${var.bucket_prefix}-${var.environment_name}-${random_string.storage_suffix.result}"
  location      = "US"
  force_destroy = true

  versioning {
    enabled = true
  }

  uniform_bucket_level_access = true
}

resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}
