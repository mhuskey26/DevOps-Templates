resource "google_sql_database_instance" "main" {
  name             = "${var.app_name}-${var.environment_name}-db-${random_string.storage_suffix.result}"
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

resource "google_sql_database" "main" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "main" {
  name     = var.db_user
  instance = google_sql_database_instance.main.name
  password = var.db_pass
}
