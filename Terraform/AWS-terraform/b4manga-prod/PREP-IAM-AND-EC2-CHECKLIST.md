# B4 Manga Terraform Pre-Prep Checklist

## Environment

- AWS Account ID: 256729431040
- AWS Region: us-west-1
- Domain: b4manga.com

## 1) Create Terraform Execution IAM Identity (Required)

Create one IAM identity that Terraform will use to deploy infrastructure.

### Recommended approach

- Create an IAM role named: terraform-deployer-b4manga-prod
- Configure trust policy to allow your operator IAM user or CI principal to assume this role
- Use AssumeRole for all Terraform runs

### Fast bootstrap option

- Temporarily attach AdministratorAccess to the Terraform role for first deployment
- After successful deployment, replace with least-privilege policies

## 2) Required Permissions for Terraform Role

The Terraform execution role must be able to create/manage:

- IAM roles, policies, instance profiles, and iam:PassRole
- VPC and networking resources (VPC, subnets, route tables, IGW, NAT, security groups)
- EC2 launch templates and Auto Scaling resources
- ALB (ELBv2) and target groups/listeners
- EFS
- RDS
- S3
- CloudWatch and CloudWatch Logs
- SSM and Secrets Manager
- KMS (if you enforce customer-managed encryption keys)

Note: Route 53 permissions are not required for this stack because DNS is managed in Cloudflare.

## 3) Remote State Backend Prep (Strongly Recommended Before First Apply)

Create backend resources in account 256729431040, region us-west-1:

- S3 bucket: wordpress-asg-terraform-state-256729431040
- DynamoDB table: wordpress-asg-terraform-locks
- DynamoDB partition key: LockID (String)

Enable on the S3 bucket:

- Versioning: Enabled
- Default encryption: Enabled
- Public access block: Enabled

Then:

1. Uncomment backend block in main.tf
2. Confirm bucket/table names
3. Run terraform init
4. Approve state migration when prompted

## 4) IAM Accounts/Roles You Need Before Terraform Apply

### Must exist before apply

- Terraform execution IAM role/user only

### Created automatically by this Terraform stack

- EC2 instance role and instance profile
- RDS enhanced monitoring role

### Optional but recommended

- Read-only audit role for operations/security
- CI deployment role (GitHub Actions/Azure DevOps) with AssumeRole access

## 5) EC2 Template Prep Requirements

No manual EC2 launch template setup is required before apply.

This stack already handles:

- Launch template creation
- Latest Amazon Linux 2023 AMI discovery
- Instance profile attachment
- User data bootstrap
- SSM-based instance access (no SSH key pair required)

Optional customization (only if needed):

- Add key_name and inbound port 22 rules if you require SSH access

## 6) Secrets and Variables Prep (Required)

Do not store sensitive values in terraform.tfvars.

Set these before running plan/apply:

PowerShell:

```powershell
$env:AWS_REGION = "us-west-1"
$env:TF_VAR_cloudflare_api_token = "<your-cloudflare-api-token>"
$env:TF_VAR_rds_db_password = "<your-strong-db-password>"
```

Bash:

```bash
export AWS_REGION="us-west-1"
export TF_VAR_cloudflare_api_token="<your-cloudflare-api-token>"
export TF_VAR_rds_db_password="<your-strong-db-password>"
```

## 7) Pre-Flight Validation Commands

Run from this folder:

- Terraform/AWS-terraform/b4manga-prod

Commands:

```bash
terraform init
terraform validate
terraform plan
```

If using PowerShell on Windows:

```powershell
terraform init
terraform validate
terraform plan
```

## 8) Optional Security Hardening After First Successful Deploy

- Replace broad bootstrap permissions with least-privilege Terraform IAM policy
- Rotate Cloudflare and database secrets
- Store secrets in AWS Secrets Manager and reference via variables/data sources
- Enable CloudTrail and access analyzer checks for IAM policy tightening

## 9) Quick Go/No-Go Checklist

- Terraform execution role exists and is assumable
- Backend S3 bucket and DynamoDB lock table exist
- Cloudflare Zone ID is set in terraform.tfvars
- TF_VAR_cloudflare_api_token is exported
- TF_VAR_rds_db_password is exported
- AWS credentials target account 256729431040 in us-west-1
- terraform validate passes
- terraform plan output is reviewed
