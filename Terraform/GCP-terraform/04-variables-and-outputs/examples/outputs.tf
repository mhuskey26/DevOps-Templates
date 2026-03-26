output "instance_internal_ip" {
  value = google_compute_instance.vm.network_interface[0].network_ip
}

output "db_instance_connection_name" {
  value = google_sql_database_instance.db_instance.connection_name
}
