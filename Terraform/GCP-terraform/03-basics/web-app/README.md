# Web Application Infrastructure

This Terraform configuration deploys a complete web application infrastructure on GCP including:

- Compute Engine instances (2 VMs)
- HTTP(S) Load Balancer
- Cloud Storage bucket with versioning
- Cloud SQL PostgreSQL database
- Cloud DNS configuration
- VPC Network with custom subnet
- Firewall rules

## Prerequisites

- GCP project created
- Required APIs enabled (Compute, SQL, DNS, Storage)
- Service account with appropriate permissions
- `GOOGLE_APPLICATION_CREDENTIALS` environment variable set
- GCS backend set up (see `/code/03-basics/gcp-backend`)

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- The Cloud SQL password should be changed and stored securely (e.g., Secret Manager)
- Cloud SQL uses db-f1-micro tier which is the smallest option
- The load balancer is a global HTTP(S) load balancer
- DNS nameservers need to be configured at your domain registrar

## DNS Nameservers

After creating the DNS zone, configure these nameservers at your domain registrar.
Get them with:
```bash
terraform output nameservers
```
