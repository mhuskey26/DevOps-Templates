output "acr_login_server" {
  description = "ACR login server URL — use as image repository prefix"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_id" {
  description = "ACR resource ID"
  value       = azurerm_container_registry.acr.id
}

output "aks_name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "aks_resource_group" {
  description = "Resource group containing the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.resource_group_name
}

output "kube_config" {
  description = "Raw kubeconfig — use with az aks get-credentials instead"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}
