# WordPress ASG Infrastructure Deployment Guide

This guide walks through the complete deployment of the WordPress infrastructure on AWS using Terraform.

## Prerequisites

### AWS Requirements
- AWS Account with appropriate IAM permissions
- VPC and EC2 permissions
- RDS permissions
- EFS permissions
- ALB and ASG permissions
- IAM role creation permissions
- S3 permissions

### Local Requirements
- Terraform >= 1.0
- AWS CLI v2 configured with credentials
- Bash shell (or Windows Subsystem for Linux on Windows)
- `jq` (optional, for parsing JSON outputs)

### AWS Credentials Setup

```bash
# Configure AWS CLI
aws configure

# Verify your credentials
aws sts get-caller-identity
```

## Step-by-Step Deployment

### Step 1: Prepare Backend Storage

Create S3 bucket and DynamoDB table for Terraform state management:

```bash
#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-west-1"
BUCKET_NAME="wordpress-asg-terraform-state-${ACCOUNT_ID}"

# Create S3 bucket
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION \
  --create-bucket-configuration LocationConstraint=$REGION

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled \
  --region $REGION

# Block public access
aws s3api put-public-access-block \
  --bucket $BUCKET_NAME \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Create DynamoDB table
aws dynamodb create-table \
  --table-name wordpress-asg-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

echo "Backend storage created:"
echo "S3 Bucket: $BUCKET_NAME"
echo "DynamoDB Table: wordpress-asg-terraform-locks"
```

### Step 2: Configure Local Backend (First Run Only)

For initial deployment, you can use local state. Later, migrate to S3:

```bash
# Initialize with local state
terraform init

# If you already created the S3 backend:
# Uncomment the backend block in main.tf
# Then run:
terraform init  # Select 'yes' to migrate to S3
```

### Step 3: Copy and Customize Variables

```bash
# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars  # or vim, code, etc.
```

**Critical variables to update:**

```hcl
# Domain configuration
domain_name        = "yourdomain.com"
route53_zone_id    = "Z1234567890ABC"  # Your hosted zone ID

# Database credentials (DO NOT use example password)
rds_db_password    = "GenerateASecurePassword123!@#"

# WordPress configuration
wordpress_admin_email = "admin@yourdomain.com"
wordpress_site_title  = "Your Site Title"

# Instance sizing
instance_type      = "t3.small"  # Adjust based on workload
asg_desired_capacity = 3         # Number of instances

# Network
vpc_cidr            = "10.0.0.0/16"
availability_zone_count = 2      # 2 or 3 for HA
```

### Step 4: Set Database Password Securely

```bash
# Option A: Environment variable
export TF_VAR_rds_db_password="YourSecurePassword123!@#"

# Option B: Use AWS Secrets Manager (recommended for production)
aws secretsmanager create-secret \
  --name wordpress/rds/password \
  --secret-string "YourSecurePassword123!@#"

# Option C: Use AWS Systems Manager Parameter Store
aws ssm put-parameter \
  --name /wordpress/rds/password \
  --value "YourSecurePassword123!@#" \
  --type SecureString
```

### Step 5: Validate Configuration

```bash
# Validate Terraform syntax
terraform validate

# Format code
terraform fmt -recursive .

# Check what will be created
terraform plan -out=tfplan

# Review the plan output carefully!
```

### Step 6: Deploy Infrastructure

```bash
# Apply the configuration
terraform apply tfplan

# Remove the plan file
rm tfplan
```

**Deployment time:** 10-15 minutes

### Step 7: Retrieve Outputs

```bash
# Show all outputs
terraform output

# Show specific outputs
terraform output alb_dns_name
terraform output rds_address
terraform output efs_dns_name
```

### Step 8: Configure WordPress

After deployment, WordPress takes 2-3 minutes to initialize. Then:

1. **Get the ALB DNS name:**
   ```bash
   ALB_DNS=$(terraform output -raw alb_dns_name)
   echo "WordPress: http://$ALB_DNS"
   ```

2. **Access WordPress installation:**
   - Open `http://<ALB_DNS>` in your browser
   - Complete the WordPress installation wizard
   - Create admin user
   - Set site title and tagline

3. **Complete WordPress setup:**
   - Install themes and plugins
   - Configure site settings
   - Add content

### Step 9: Configure HTTPS (Recommended)

For production, enable HTTPS:

1. **Request ACM certificate:**
   ```bash
   aws acm request-certificate \
     --domain-name yourdomain.com \
     --subject-alternative-names "*.yourdomain.com" \
     --validation-method DNS
   ```

2. **Update Terraform variables:**
   ```hcl
   alb_enable_https      = true
   acm_certificate_arn   = "arn:aws:acm:region:account:certificate/uuid"
   ```

3. **Reapply configuration:**
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

### Step 10: Configure DNS

If using Route 53:

```bash
# Terraform already created the records if route53_zone_id was set
# Verify:
aws route53 list-resource-record-sets \
  --hosted-zone-id Z1234567890ABC \
  --query "ResourceRecordSets[?Name=='yourdomain.com.']"

# If not created, enable in terraform.tfvars:
# route53_zone_id = "Z1234567890ABC"
```

## Post-Deployment Configuration

### Enable CloudWatch Monitoring

All CloudWatch alarms are created automatically. To enable SNS notifications:

```bash
# Create SNS topic for alarms
aws sns create-topic --name wordpress-asg-alerts

# Update alarm actions in asg.tf, alb.tf, rds.tf to include SNS topic ARN
```

### Configure Database Backups

Backups are configured in RDS with 30-day retention. To restore:

```bash
# List available backups
aws rds describe-db-snapshots \
  --db-instance-identifier wordpress-asg-prod-db

# Restore from snapshot
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier wordpress-asg-restored \
  --db-snapshot-identifier <snapshot-id>
```

### Enable Media Offload to S3

Install a WordPress plugin to offload media to S3:

1. Install "WP Offload Media"
2. Configure AWS credentials
3. Set bucket to `<terraform output s3_bucket_name>`

### Enable Redis Caching

To add Redis for object caching:

```hcl
# In a new file, add:
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${local.name_prefix}-redis"
  engine               = "redis"
  node_type            = "cache.t4g.micro"
  num_cache_nodes      = 1
  availability_zones   = [local.azs[0]]
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  port                 = 6379
  security_group_ids   = [aws_security_group.redis.id]
}
```

## Scaling

### Horizontal Scaling

Adjust the number of instances:

```bash
# Update in terraform.tfvars
asg_desired_capacity = 5

# Apply change
terraform apply
```

### Vertical Scaling

Change instance type:

```bash
# Update in terraform.tfvars
instance_type = "t3.medium"

# Apply (instances will be replaced)
terraform apply
```

### Database Scaling

For RDS, modify the instance class:

```bash
# Update in terraform.tfvars
rds_instance_class = "db.t4g.medium"

# Apply (causes brief downtime)
terraform apply
```

## Monitoring

### View Application Logs

```bash
# EC2 bootstrap logs
aws ssm start-session --target <instance-id>
tail -f /var/log/wordpress-bootstrap.log

# Apache logs
tail -f /var/log/httpd/wordpress-error.log
tail -f /var/log/httpd/wordpress-access.log

# PHP logs
tail -f /var/log/php-fpm/www-error.log
```

### CloudWatch Metrics

```bash
# Monitor ASG
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "wordpress-asg-prod-asg"

# Monitor EFS
aws cloudwatch get-metric-statistics \
  --namespace AWS/EFS \
  --metric-name BurstCreditBalance \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average
```

### CloudWatch Logs Insights

```bash
# Check ECS logs
aws logs start-query \
  --log-group-name "/aws/vpc/flowlogs/wordpress-asg-prod" \
  --start-time 1704067200 \
  --end-time 1704153600 \
  --query-string "fields @message | stats count() by action"
```

## Troubleshooting

### Instances Not Health Checking

```bash
# Check ALB target health
aws elbv2 describe-target-health \
  --target-group-arn <arn-from-terraform-output>

# Connect to instance
aws ssm start-session --target <instance-id>

# Check startup logs
tail -f /var/log/wordpress-bootstrap.log

# Check EFS mount
df -h | grep efs

# Check Apache
systemctl status httpd
tail -f /var/log/httpd/wordpress-error.log
```

### EFS Mount Failures

```bash
# Check mount
mount | grep efs

# Check security groups
aws ec2 describe-security-groups \
  --group-ids <efs-sg-id>

# Remount if needed
sudo umount /mnt/efs
sudo mount -a
```

### Database Connection Issues

```bash
# Test connectivity
mysql -h <rds-endpoint> -u wpadmin -p -e "SELECT 1;"

# Check RDS security group
aws ec2 describe-security-groups \
  --group-ids <rds-sg-id>

# Check RDS status
aws rds describe-db-instances \
  --db-instance-identifier wordpress-asg-prod-db
```

### ALB Not Forwarding Traffic

```bash
# Check listener configuration
aws elbv2 describe-listeners \
  --load-balancer-arn <alb-arn>

# Check target group
aws elbv2 describe-target-groups \
  --load-balancer-arn <alb-arn>

# Check security group ingress
aws ec2 describe-security-groups \
  --group-ids <alb-sg-id>
```

## Maintenance

### Backup and Restore

```bash
# Manual RDS snapshot
aws rds create-db-snapshot \
  --db-instance-identifier wordpress-asg-prod-db \
  --db-snapshot-identifier wordpress-asg-prod-backup-$(date +%Y%m%d)

# Backup EFS
# Use AWS DataSync or manual copy to S3

# Backup WordPress files
tar -czf wordpress-backup-$(date +%Y%m%d).tar.gz /var/www/html/
aws s3 cp wordpress-backup-*.tar.gz s3://wordpress-asg-bucket/backups/
```

### Updates and Patches

```bash
# Update launch template
# Change AMI or instance type in terraform.tfvars
terraform plan
terraform apply

# ASG will replace instances one by one

# Update WordPress plugins
# Via wp-admin or wp-cli:
wp plugin update --all
```

### Cost Optimization

```bash
# View current costs
terraform output wordpress_access_info

# Estimate costs
terraform plan -json | terraform-cost-estimation

# Reduce costs:
# 1. Lower instance_type to t3.micro
# 2. Reduce asg_desired_capacity
# 3. Use RDS read replicas instead of separate instances
```

## Cleanup and Destruction

```bash
# Backup before destroying
aws rds create-db-snapshot \
  --db-instance-identifier wordpress-asg-prod-db \
  --db-snapshot-identifier wordpress-asg-prod-final-backup

# Destroy infrastructure
terraform destroy

# Remove state files
rm -rf .terraform/
rm .terraform.lock.hcl

# Empty and delete S3 buckets manually via AWS Console
# (Terraform won't delete non-empty S3 buckets)
```

## Support and Documentation

- Terraform Documentation: https://www.terraform.io/docs/
- AWS Documentation: https://docs.aws.amazon.com/
- WordPress Documentation: https://wordpress.org/documentation/
- Architecture Reference: See WORDPRESS-ASG-REFERENCE-ARCHITECTURE.md

## Security Checklist

- [ ] Changed all default passwords
- [ ] Enabled HTTPS with valid certificate
- [ ] Configured security groups properly
- [ ] Enabled CloudWatch alarms
- [ ] Enabled RDS backups
- [ ] Configured VPC Flow Logs
- [ ] Enabled S3 versioning and encryption
- [ ] Removed any hardcoded secrets from code
- [ ] Tested disaster recovery procedure
- [ ] Reviewed IAM permissions for least privilege
- [ ] Enabled access logging for ALB and S3
- [ ] Configured AWS Config for compliance
- [ ] Enabled CloudTrail for audit logging

## Notes

- Initial deployment takes 10-15 minutes
- EC2 instances take 2-3 minutes to fully initialize
- RDS backups take a few minutes on initial creation
- Always test changes in dev before applying to prod
- Keep Terraform state file secure (use remote state with encryption)
