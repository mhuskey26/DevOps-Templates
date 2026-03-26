output "instance_1_internal_ip" {
  value = google_compute_instance.instance_1.network_interface[0].network_ip
}

output "instance_2_internal_ip" {
  value = google_compute_instance.instance_2.network_interface[0].network_ip
}

output "db_connection_name" {
  value = google_sql_database_instance.webapp.connection_name
}

output "load_balancer_ip" {
  value = google_compute_global_address.webapp.address
}
