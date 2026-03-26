## GCP Module Example

This example demonstrates using third-party modules from the Terraform Registry.

### GCP Modules from Registry

The Terraform Registry has many community and Google-verified modules:

```terraform
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "~> 23.0"
  
  project_id = "my-project"
  name       = "my-cluster"
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 6.0"
  
  project_id   = "my-project"
  network_name = "my-network"
}
```

Browse modules at: https://registry.terraform.io/browse/modules?provider=google

For this example, we'll create a placeholder showing how to reference GCP modules from the registry.
