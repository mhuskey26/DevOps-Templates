# Quick Start Guide

Get your WordPress infrastructure running in 5 minutes:

## Prerequisites

```bash
# Check you have terraform installed
terraform version  # Should be 1.0 or higher

# Check AWS CLI is configured
aws sts get-caller-identity
```

## Quick Deploy

### 1. Copy and Edit Variables (2 minutes)

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

**Minimum changes needed:**
```hcl
domain_name = "yourdomain.com"
rds_db_password = "GenerateASecurePassword123!@#"
```

### 2. Initialize and Deploy (10-15 minutes)

```bash
terraform init
terraform plan
terraform apply
```

### 3. Get Your Endpoints (1 minute)

```bash
terraform output wordpress_access_info
```

### 4. Access WordPress (when ready)

Open the ALB DNS name from the outputs in your browser:
```
http://<ALB_DNS_NAME>
```

Complete the WordPress setup wizard in the browser.

## That's It!

Your WordPress infrastructure is now deployed with:
✅ Multi-AZ Application Load Balancer
✅ Auto Scaling EC2 instances (2-6 instances)
✅ Shared EFS for wp-content
✅ RDS MySQL database
✅ S3 for backups and media
✅ Security groups and IAM roles configured
✅ CloudWatch monitoring and alarms

## Common Commands

```bash
# See all infrastructure details
terraform output

# Scale up to 5 instances
terraform apply -var="asg_desired_capacity=5"

# View deployment status
terraform show

# Destroy everything (careful!)
terraform destroy
```

## Troubleshooting

### Instances not healthy?
```bash
# Check instance logs
aws ssm start-session --target $(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=wordpress-asg-*" \
  --query 'Reservations[0].Instances[0].InstanceId' --output text)

# View bootstrap log
tail -f /var/log/wordpress-bootstrap.log
```

### Database connection issues?
```bash
# Test database
mysql -h $(terraform output -raw rds_address) \
  -u wpadmin -p \
  -e "SELECT 1;"
```

### EFS not mounting?
```bash
# Check mount
mount | grep efs

# Remount
sudo mount -a
```

## Next Steps

1. **Enable HTTPS:**
   - Request ACM certificate
   - Update `alb_enable_https = true`
   - Set `acm_certificate_arn` to your certificate ARN

2. **Configure DNS:**
   - Set `route53_zone_id` to your hosted zone ID

3. **Scale up:**
   - Update `asg_desired_capacity` or let auto-scaling handle it

4. **Add monitoring:**
   - Create SNS topics for alarm notifications
   - Set up CloudWatch dashboards

5. **Backup strategy:**
   - Configure RDS automated backups (default: 30 days)
   - Backup EFS to S3 regularly
   - Test restore procedures

## Documentation

- Full guide: [DEPLOYMENT.md](DEPLOYMENT.md)
- Architecture: [../WORDPRESS-ASG-REFERENCE-ARCHITECTURE.md](../WORDPRESS-ASG-REFERENCE-ARCHITECTURE.md)
- README: [README.md](README.md)

## Support

Issues? Check:
1. [DEPLOYMENT.md - Troubleshooting](DEPLOYMENT.md#troubleshooting)
2. CloudWatch logs
3. EC2 instance system logs
4. RDS events
