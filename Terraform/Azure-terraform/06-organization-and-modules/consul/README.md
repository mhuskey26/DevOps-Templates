## Consul Module Example

This example demonstrates using a third-party module from the Terraform Registry.

### Azure Consul Module

While there isn't an exact Azure equivalent of the AWS Consul module, you can:

1. Use the official HashiCorp Consul Helm chart on Azure Kubernetes Service (AKS)
2. Deploy Consul on Azure VMs using custom configurations
3. Use Azure-native service mesh alternatives like:
   - Azure Service Fabric
   - Istio on AKS
   - Linkerd on AKS

### Example AKS with Consul:

```terraform
module "aks_cluster" {
  source = "Azure/aks/azurerm"
  
  resource_group_name = "consul-rg"
  location            = "East US"
  cluster_name        = "consul-cluster"
}

# Then use Helm to install Consul
```

For this example, we'll create a placeholder showing how to reference Azure modules from the registry.
