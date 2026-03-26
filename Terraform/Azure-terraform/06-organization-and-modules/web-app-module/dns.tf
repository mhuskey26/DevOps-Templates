resource "azurerm_dns_zone" "primary" {
  count               = var.create_dns_zone ? 1 : 0
  name                = var.domain
  resource_group_name = azurerm_resource_group.main.name
}

data "azurerm_dns_zone" "primary" {
  count               = var.create_dns_zone ? 0 : 1
  name                = var.domain
  resource_group_name = azurerm_resource_group.main.name
}

locals {
  dns_zone_name = var.create_dns_zone ? azurerm_dns_zone.primary[0].name : data.azurerm_dns_zone.primary[0].name
  subdomain     = var.environment_name == "production" ? "@" : var.environment_name
}

resource "azurerm_dns_a_record" "root" {
  name                = local.subdomain
  zone_name           = local.dns_zone_name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  target_resource_id  = azurerm_public_ip.appgw.id
}
