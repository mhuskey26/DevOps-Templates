# WordPress on AWS with ALB + ASG + EFS + RDS

Enterprise-grade Terraform deployment for a highly available WordPress environment on AWS.

## Architecture

- Multi-AZ VPC with public and private subnets
- Application Load Balancer (ALB) for load distribution
- Auto Scaling Group (ASG) with EC2 instances running WordPress
- Amazon EFS for shared WordPress content
- Amazon RDS MySQL database
- S3 bucket for backups and media offload
- Route 53 for DNS (optional)
- ACM for HTTPS certificates (optional)

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.0
- AWS CLI configured with credentials
- An existing Route 53 hosted zone (if using DNS via Terraform)
- An existing ACM certificate or ability to create one (if using HTTPS)

## Directory Structure

```
.
├── main.tf                          # Provider and local configuration
├── backend.tf                       # Remote state backend configuration
├── variables.tf                     # Input variables
├── terraform.tfvars.example         # Example variable values
├── networking.tf                    # VPC, subnets, route tables
├── security_groups.tf               # Security groups for all components
├── iam.tf                           # IAM roles and instance profile
├── efs.tf                           # EFS configuration
├── rds.tf                           # RDS database configuration
├── alb.tf                           # Application Load Balancer
├── launch_template.tf               # EC2 launch template with user data
├── asg.tf                           # Auto Scaling Group
├── s3.tf                            # S3 bucket for backups
├── route53.tf                       # Route 53 DNS configuration (optional)
├── outputs.tf                       # Output values
├── README.md                        # This file
└── ../WORDPRESS-ASG-REFERENCE-ARCHITECTURE.md  # Architecture documentation
```

## Quick Start

### 1. Initialize Backend

Create an S3 bucket and DynamoDB table for remote state before deploying:

```bash
aws s3api create-bucket \
  --bucket wordpress-asg-terraform-state-$(aws sts get-caller-identity --query Account --output text) \
  --region us-west-1 \
  --create-bucket-configuration LocationConstraint=us-west-1

aws s3api put-bucket-versioning \
  --bucket wordpress-asg-terraform-state-$(aws sts get-caller-identity --query Account --output text) \
  --versioning-configuration Status=Enabled \
  --region us-west-1

aws dynamodb create-table \
  --table-name wordpress-asg-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-west-1
```

### 2. Configure Variables

Copy the example variables file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific configuration:
- AWS region
- VPC and subnet CIDRs
- Domain name
- Database credentials (use AWS Secrets Manager in production)
- Instance type and scaling parameters
- Tags and naming conventions

### 3. Configure Backend

Update `backend.tf` with your S3 bucket and DynamoDB table names.

### 4. Plan Deployment

```bash
terraform init
terraform plan -out=wordpress.tfplan
```

### 5. Apply Configuration

```bash
terraform apply wordpress.tfplan
```

### 6. Retrieve Outputs

```bash
terraform output
```

## Important Notes

### Secrets Management

**Do not store passwords in `terraform.tfvars`.** Use one of these approaches:

1. **AWS Secrets Manager** (recommended for production):
   - Create the secret in AWS Secrets Manager manually
   - Reference it in the bootstrap script
   - Grant EC2 IAM role read permissions

2. **AWS Systems Manager Parameter Store**:
   - Store sensitive values as SecureString parameters
   - Retrieve them in the EC2 bootstrap script

3. **Environment Variables**:
   ```bash
   export TF_VAR_rds_password="your-password"
   terraform plan
   ```

### State Management

Remote state is configured in `backend.tf`. Ensure:
- Backend S3 bucket has versioning enabled
- DynamoDB table is configured for state locks
- Appropriate IAM permissions are set
- Backend files are not committed to version control

### Security Best Practices

- RDS credentials are stored in AWS Secrets Manager (placeholder in Terraform)
- Database is in private subnets with no direct internet access
- EC2 instances do not have public IP addresses by default
- ALB is the only public-facing component
- All security groups follow the principle of least privilege
- Enable VPC Flow Logs for monitoring
- Use AWS Systems Manager instead of SSH where possible
- Enable CloudWatch logging for ALB and RDS

### Bootstrap Script

The EC2 instances use a bootstrap script stored at:
`../../../Linux/BashScripts/Ubuntu/Apache.bash`

Update the script path in `launch_template.tf` if you move the bootstrap script.

## Scaling Considerations

### Application Scaling

- Adjust `min_size`, `max_size`, and `desired_capacity` in `asg.tf`
- Configure scaling policies based on CloudWatch metrics
- Monitor EFS burst credits if using BurstThroughputMode

### Database Scaling

- RDS is configured with a single instance; use Aurora for multi-AZ replica sets
- Consider Read Replicas for reporting workloads
- Monitor RDS performance via CloudWatch

### Storage Scaling

- EFS automatically scales; no provisioning needed for General Purpose mode
- Monitor burst credit consumption
- Consider Provisioned Throughput mode for predictable workloads

## Monitoring and Logging

### CloudWatch Metrics to Monitor

- ALB: request count, target health, latency, HTTP 5xx errors
- ASG: running instances, desired capacity, terminating instances
- EFS: burst credit balance, throughput, mount target availability
- RDS: CPU utilization, database connections, slow query logs
- EC2: system status checks, instance reachability

### Recommended CloudWatch Alarms

- ALB unhealthy target count > 0
- ASG desired capacity != running instances
- EFS burst credit balance < 10%
- RDS CPU > 80%
- RDS storage space < 10GB free

## Destroying Resources

**WARNING:** This will delete all resources including databases. Ensure backups exist first.

```bash
terraform destroy
```

To destroy only specific resources:

```bash
terraform destroy -target=aws_autoscaling_group.wordpress
```

## Troubleshooting

### Instances Not Passing Health Checks

1. Check ALB target group health: `aws elbv2 describe-target-health --target-group-arn <arn>`
2. SSH into instance via Systems Manager: `aws ssm start-session --target i-xxxxx`
3. Check logs: `tail -f /var/log/wordpress-bootstrap.log`
4. Verify EFS mount: `df -h | grep efs`

### EFS Mount Failures

1. Ensure security group allows NFS (port 2049) from EC2 security group
2. Verify EFS DNS name is correct
3. Check mount target availability in each AZ

### Database Connection Failures

1. Verify RDS security group allows port 3306 from EC2 security group
2. Confirm RDS endpoint DNS is correct
3. Test with: `mysql -h <rds-endpoint> -u <user> -p`

### Auto Scaling Not Working

1. Verify launch template is up to date
2. Check for insufficient capacity errors in ASG activity history
3. Verify IAM role has appropriate permissions
4. Monitor CloudWatch for scaling policy triggers

## Advanced Configuration

### Adding CloudFront

See comments in `s3.tf` for CloudFront distribution configuration.

### Adding Redis Cache

Add ElastiCache cluster for WordPress object caching:

```hcl
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 2
  availability_zones   = data.aws_availability_zones.available.names
  # ... additional configuration
}
```

### Adding WAF

Attach AWS WAF to the ALB for protection against common web exploits.

## Cost Estimation

Use the AWS Cost Calculator or Terraform Cloud's cost estimation feature:

```bash
terraform plan -json | tf-cost-estimate
```

Rough monthly costs (us-west-1, as of 2026):
- ALB: ~$15/month
- EC2 (t3.small, 3 instances): ~$30/month
- EFS: ~$30/month (depends on storage)
- RDS (db.t4g.small): ~$50/month
- S3: minimal (~$1/month)
- Data transfer: varies

**Total: ~$125-150/month for a small to medium setup**

## Support and Contributing

For issues or improvements, refer to the repository documentation or contact your infrastructure team.

## License

Copyright © 2026. All rights reserved.
