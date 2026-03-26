## 03 - Basics

## Remote Backends

Remote backends enable storage of TF state in a remote location to enable secure collaboration.

### Terraform Cloud

https://www.terraform.io/cloud

`./terraform-cloud-backend/main.tf`

### GCP Cloud Storage

Steps to initialize backend in GCP and manage it with Terraform:

1) Use config from `./gcp-backend/` (init, plan, apply) to provision Cloud Storage bucket with local state
2) Uncomment the remote backend configuration
3) Reinitialize with `terraform init`:

```
Do you want to copy existing state to the new backend?
  Pre-existing state was found while migrating the previous "local" backend to the
  newly configured "gcs" backend. No existing state was found in the newly
  configured "gcs" backend. Do you want to copy this state to the new "gcs"
  backend? Enter "yes" to copy and "no" to start with an empty state.

  Enter a value: yes 
```

Now the Cloud Storage bucket is managed and is able to be used as the state backend!

Note: GCS backend has built-in state locking, no separate table needed like AWS DynamoDB.

## Web-App

Generic web application architecture including:
- Compute Engine instances
- Cloud Storage bucket
- Cloud SQL instance
- Load Balancer
- Cloud DNS config

This example will be refined and improved in later modules.

## Architecture
![](./web-app/architecture.png)
