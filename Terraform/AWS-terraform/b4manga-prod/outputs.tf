# Consolidated Outputs for WordPress ASG Infrastructure

# VPC and Networking Outputs
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "The CIDR block of the VPC"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "IDs of public subnets"
}

output "private_app_subnet_ids" {
  value       = aws_subnet.private_app[*].id
  description = "IDs of private application subnets"
}

output "private_db_subnet_ids" {
  value       = aws_subnet.private_db[*].id
  description = "IDs of private database subnets"
}

# Security Group Outputs
output "alb_security_group_id" {
  value       = aws_security_group.alb.id
  description = "Security group ID for ALB"
}

output "ec2_security_group_id" {
  value       = aws_security_group.ec2.id
  description = "Security group ID for EC2 instances"
}

output "efs_security_group_id" {
  value       = aws_security_group.efs.id
  description = "Security group ID for EFS"
}

output "rds_security_group_id" {
  value       = aws_security_group.rds.id
  description = "Security group ID for RDS"
}

# ALB Outputs
output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "DNS name of the ALB"
}

output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ARN of the ALB"
}

output "alb_zone_id" {
  value       = aws_lb.main.zone_id
  description = "Zone ID of the ALB (useful for Route 53)"
}

# EFS Outputs
output "efs_id" {
  value       = aws_efs_file_system.wordpress.id
  description = "ID of the EFS file system"
}

output "efs_dns_name" {
  value       = aws_efs_file_system.wordpress.dns_name
  description = "DNS name of the EFS file system"
}

output "efs_arn" {
  value       = aws_efs_file_system.wordpress.arn
  description = "ARN of the EFS file system"
}

output "efs_mount_target_ids" {
  value       = aws_efs_mount_target.wordpress[*].id
  description = "IDs of EFS mount targets"
}

# RDS Outputs
output "rds_endpoint" {
  value       = aws_db_instance.wordpress.endpoint
  description = "RDS database endpoint"
  sensitive   = true
}

output "rds_address" {
  value       = aws_db_instance.wordpress.address
  description = "RDS database address"
}

output "rds_port" {
  value       = aws_db_instance.wordpress.port
  description = "RDS database port"
}

output "rds_database_name" {
  value       = aws_db_instance.wordpress.db_name
  description = "Name of the WordPress database"
}

output "rds_master_username" {
  value       = aws_db_instance.wordpress.username
  description = "Master username for RDS"
}

output "rds_resource_id" {
  value       = aws_db_instance.wordpress.resource_id
  description = "RDS resource ID"
}

# S3 Outputs
output "s3_bucket_name" {
  value       = aws_s3_bucket.wordpress.id
  description = "Name of the S3 bucket for backups and media"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.wordpress.arn
  description = "ARN of the S3 bucket"
}

output "s3_logs_bucket_name" {
  value       = var.s3_enable_logging ? aws_s3_bucket.wordpress_logs[0].id : null
  description = "Name of the S3 logs bucket"
}

# Auto Scaling Group Outputs
output "asg_name" {
  value       = aws_autoscaling_group.wordpress.name
  description = "Name of the Auto Scaling Group"
}

output "asg_arn" {
  value       = aws_autoscaling_group.wordpress.arn
  description = "ARN of the Auto Scaling Group"
}

output "asg_desired_capacity" {
  value       = aws_autoscaling_group.wordpress.desired_capacity
  description = "Desired capacity of the ASG"
}

output "asg_min_size" {
  value       = aws_autoscaling_group.wordpress.min_size
  description = "Minimum size of the ASG"
}

output "asg_max_size" {
  value       = aws_autoscaling_group.wordpress.max_size
  description = "Maximum size of the ASG"
}

# Launch Template Outputs
output "launch_template_id" {
  value       = aws_launch_template.wordpress.id
  description = "ID of the launch template"
}

output "launch_template_latest_version" {
  value       = aws_launch_template.wordpress.latest_version_number
  description = "Latest version number of the launch template"
}

output "ami_id" {
  value       = data.aws_ami.amazon_linux_2023.id
  description = "AMI ID used for instances"
}

output "ami_name" {
  value       = data.aws_ami.amazon_linux_2023.name
  description = "AMI name used for instances"
}

# Route 53 and DNS configuration removed - using Cloudflare instead

# IAM Outputs
output "ec2_role_arn" {
  value       = aws_iam_role.ec2_role.arn
  description = "ARN of the EC2 IAM role"
}

output "ec2_instance_profile_name" {
  value       = aws_iam_instance_profile.ec2_profile.name
  description = "Name of the EC2 instance profile"
}

# Summary Output
output "wordpress_access_info" {
  value = {
    alb_dns = aws_lb.main.dns_name
    site_domain = var.domain_name
    wordpress_url = "http://${aws_lb.main.dns_name}"
    admin_url = "http://${aws_lb.main.dns_name}/wp-admin"
    database_host = aws_db_instance.wordpress.address
    database_name = var.rds_db_name
    database_user = var.rds_db_username
    efs_mount_point = "/mnt/efs"
    shared_content_path = "/var/www/html/wp-content"
  }
  description = "Quick reference for WordPress access information"
}

# Next Steps Output
output "next_steps" {
  value = <<-EOT
    WordPress infrastructure deployment is complete!

    1. ALB DNS: ${aws_lb.main.dns_name}
    2. Access WordPress at: http://${aws_lb.main.dns_name}
    3. WordPress Admin: http://${aws_lb.main.dns_name}/wp-admin
    
    Database Information:
    - Host: ${aws_db_instance.wordpress.address}
    - Database: ${var.rds_db_name}
    - User: ${var.rds_db_username}
    
    EFS Storage:
    - File System ID: ${aws_efs_file_system.wordpress.id}
    - Mount Point: /mnt/efs
    - Shared Content: /var/www/html/wp-content

    S3 Bucket:
    - Bucket Name: ${aws_s3_bucket.wordpress.id}
    - For backups and media offload

    Cloudflare DNS Configuration:
    1. Log in to Cloudflare dashboard (https://dash.cloudflare.com)
    2. Add or select your domain (${var.domain_name})
    3. Update nameservers to point to Cloudflare
    4. Create DNS A record pointing to ALB: ${aws_lb.main.dns_name}
    5. Enable proxy (orange cloud) in Cloudflare
    6. Cloudflare will automatically issue SSL/TLS certificate

    Configure WordPress:
    1. Wait 2-3 minutes for EC2 instances to fully initialize
    2. Once Cloudflare DNS is active, navigate to https://${var.domain_name}
    3. Complete WordPress installation wizard
    4. Configure site title and admin account

    Important:
    - All instances are in private subnets (no direct SSH)
    - Use AWS Systems Manager Session Manager for access
    - Database password is stored in state file (move to Secrets Manager for production)
    - ALB listens on HTTP (port 80) only; Cloudflare handles HTTPS at the edge
    - Cloudflare automatically manages SSL/TLS certificates

    To scale:
    - Update asg_desired_capacity and run: terraform apply
    - Or let Auto Scaling policies handle it based on metrics
    
    To destroy:
    - Run: terraform destroy
    - Ensure RDS backups exist before destruction

    Documentation: See WORDPRESS-ASG-REFERENCE-ARCHITECTURE.md
  EOT
  description = "Next steps for completing WordPress setup"
}
