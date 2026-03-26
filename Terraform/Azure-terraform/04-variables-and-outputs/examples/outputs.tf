output "vm_private_ip" {
  value = azurerm_linux_virtual_machine.vm.private_ip_address
}

output "db_server_fqdn" {
  value = azurerm_postgresql_server.db_server.fqdn
}
