output "vm_1_private_ip" {
  value = azurerm_linux_virtual_machine.instance_1.private_ip_address
}

output "vm_2_private_ip" {
  value = azurerm_linux_virtual_machine.instance_2.private_ip_address
}

output "db_server_fqdn" {
  value = azurerm_postgresql_server.main.fqdn
}

output "appgw_public_ip" {
  value = azurerm_public_ip.appgw.ip_address
}
