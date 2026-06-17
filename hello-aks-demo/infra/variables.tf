variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-aks-demo"
}

variable "acr_name" {
  description = "Azure Container Registry name (globally unique, alphanumeric)"
  type        = string
  default     = "mydemoacr"
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "aks-demo"
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 2
}
