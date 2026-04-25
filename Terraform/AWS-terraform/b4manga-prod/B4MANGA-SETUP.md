# B4 Manga Production Setup Guide

This directory contains the WordPress ASG infrastructure configured specifically for **B4 Manga Production** (`b4manga.com`).

## Quick Start

### 1. Set Environment Variables

Before deploying, set the Cloudflare API credentials and RDS password:

```bash
# Set Cloudflare API Token/Key
# Using legacy API Key (as provided):
export TF_VAR_cloudflare_api_token="85f70c2faba1eac83a2c9f0bbbf653d8c1b63"

# Set RDS Database Password (generate a secure one!)
export TF_VAR_rds_db_password="GenerateAStrongPassword123!@#$%"

# Verify they're set
echo "Cloudflare Token: $TF_VAR_cloudflare_api_token"
echo "RDS Password: [hidden]"
```

### 2. Get Cloudflare Zone ID

1. Log in to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Select domain: **b4manga.com**
3. Go to **Settings → General**
4. Copy the **Zone ID** (32-character string)
5. Update `terraform.tfvars`:
   ```hcl
   cloudflare_zone_id = "your-zone-id-here"
   ```

### 3. Validate and Deploy

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Preview changes
terraform plan -out=tfplan

# Deploy infrastructure (takes 10-15 minutes)
terraform apply tfplan
```

### 4. Configure Cloudflare DNS After Deployment

Once Terraform completes:

1. Get ALB DNS name:
   ```bash
   terraform output alb_dns_name
   ```

2. In Cloudflare dashboard for **b4manga.com**:
   - Go to **DNS → Records**
   - Create an **A record**:
     - Name: `@`
     - Content: [ALB DNS name from above]
     - TTL: Auto
     - Proxy: **Proxied (orange cloud)** ← Important!

3. Wait 5-30 minutes for DNS propagation and SSL certificate issuance

4. Access your site:
   ```bash
   # HTTP (redirected to HTTPS by Cloudflare)
   curl -I http://b4manga.com
   
   # HTTPS (fully working)
   curl -I https://b4manga.com
   ```

## Infrastructure Details

### Credentials Used

| Service | Account | Key |
|---------|---------|-----|
| Cloudflare Email | `it@b4manga.com` | Configured |
| Cloudflare Zone | `b4manga.com` | Zone ID required |
| RDS Master User | `b4admin` | Password from TF_VAR_rds_db_password |
| WordPress Database | `b4manga` | Created automatically |

### Sizing

- **EC2 Instances**: t3.medium (production-grade)
- **Min/Max/Desired**: 3/10/3 instances
- **RDS**: db.t4g.medium with Multi-AZ
- **EFS**: Bursting mode (scales automatically)
- **Storage**: 50GB (EC2), 100GB (RDS)

### Features

✅ Multi-AZ high availability (2 availability zones)
✅ Auto-scaling based on CPU and request count
✅ Cloudflare DNS and SSL/TLS at edge
✅ EFS for shared WordPress content (plugins, themes)
✅ RDS MySQL 8.0 with backups and monitoring
✅ S3 bucket for backups and media offload
✅ CloudWatch monitoring and alarms
✅ VPC with private subnets for security

## Post-Deployment

### Access WordPress Admin

1. Wait 2-3 minutes for EC2 instances to boot
2. Navigate to `https://b4manga.com/wp-admin`
3. Complete WordPress setup:
   - Site title: B4 Manga (already configured)
   - Admin email: admin@b4manga.com (already configured)
   - Create admin user account
   - Set password

### Enable Media Offload to S3

1. Install "WP Offload Media" plugin in WordPress
2. Configure with AWS credentials
3. Set bucket to: `b4manga-prod-bucket-[account-id]`

### Enable Redis Caching

For better performance, consider adding Redis:

```bash
# Uncomment and configure ElastiCache in infrastructure
# See terraform files for Redis configuration options
```

### Monitoring

CloudWatch dashboards and alarms are automatically created:

```bash
# View alarms
aws cloudwatch describe-alarms --alarm-names "*b4manga*"

# View logs
aws logs tail /aws/lambda/b4manga-prod-function --follow
```

## Scaling

### Horizontal Scaling

```bash
# Scale to more instances
terraform apply -var="asg_desired_capacity=5"
```

### Vertical Scaling

```bash
# Larger instance type
terraform apply -var="instance_type=t3.large"
```

## Troubleshooting

### Instances not healthy?
```bash
# Check ALB target health
aws elbv2 describe-target-health --target-group-arn arn:...

# Check instance logs via Systems Manager
aws ssm start-session --target i-xxxxxxxx
tail -f /var/log/wordpress-bootstrap.log
```

### DNS not resolving?
```bash
# Check Cloudflare DNS propagation
nslookup b4manga.com
dig b4manga.com

# Check Cloudflare status
curl -I https://b4manga.com
```

### Database connection issues?
```bash
# Test database
mysql -h $(terraform output -raw rds_address) \
  -u b4admin -p \
  -e "SELECT 1;"
```

## Backup & Disaster Recovery

### RDS Snapshots

```bash
# Create manual snapshot
aws rds create-db-snapshot \
  --db-instance-identifier b4manga-prod-db \
  --db-snapshot-identifier b4manga-prod-backup-$(date +%Y%m%d)

# List snapshots
aws rds describe-db-snapshots \
  --db-instance-identifier b4manga-prod-db
```

### EFS Backup to S3

```bash
# Backup EFS to S3
tar -czf b4manga-backup-$(date +%Y%m%d).tar.gz /mnt/efs
aws s3 cp b4manga-backup-*.tar.gz s3://b4manga-prod-bucket-[account-id]/backups/
```

## Cost Optimization

**Current estimated monthly costs** (t3.medium, 3 instances):
- ALB: ~$15
- EC2: ~$60 (3x t3.medium)
- RDS: ~$100 (db.t4g.medium Multi-AZ)
- EFS: ~$30-50
- S3: ~$5
- Data transfer: ~$20
- **Total: ~$230-250/month**

To reduce:
- Scale down to t3.small instances
- Use single-AZ RDS (less reliable)
- Enable S3 lifecycle policies
- Use CloudFront for caching

## Destruction

**⚠️ WARNING: This will delete all resources including the database!**

```bash
# Backup first!
aws rds create-db-snapshot \
  --db-instance-identifier b4manga-prod-db \
  --db-snapshot-identifier b4manga-prod-final-backup

# Then destroy
terraform destroy

# Clean up state files
rm -rf .terraform/
rm .terraform.lock.hcl
```

## Support

For issues or questions:
1. Check [DEPLOYMENT.md](../wordpress-asg-infra/DEPLOYMENT.md)
2. Review [README.md](../wordpress-asg-infra/README.md)
3. Check Terraform state: `terraform show`
4. Check AWS CloudWatch logs and alarms

---

**Created**: April 25, 2026
**Domain**: b4manga.com
**Environment**: Production
**Managed By**: Terraform
