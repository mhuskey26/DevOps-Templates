## 02 - Overview + Setup

## Install Terraform

Official installation instructions from HashiCorp: https://learn.hashicorp.com/tutorials/terraform/install-cli

## GCP Account Setup

GCP Terraform provider documentation: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started

1) Create a GCP project
2) Enable required APIs (Compute Engine, Cloud SQL, Cloud DNS, etc.)
3) Create a service account with necessary permissions
4) Download the service account key JSON file
5) Set the environment variable:
   ```bash
   export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
   ```

Alternative: Use gcloud CLI authentication with `gcloud auth application-default login`

## Hello World

`./main.tf` contains minimal configuration to provision a Compute Engine VM instance.

1) `gcloud auth application-default login` (or set GOOGLE_APPLICATION_CREDENTIALS)
2) `terraform init`
3) `terraform plan`
4) `terraform apply`

## Required GCP APIs

Enable these APIs in your project:
- Compute Engine API
- Cloud SQL Admin API
- Cloud DNS API
- Cloud Storage API
