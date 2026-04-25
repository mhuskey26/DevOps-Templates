# AWS Region
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-1"
}

# Project identification
variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "wordpress-asg"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# Networking
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "availability_zone_count" {
  description = "Number of AZs to use (2-3 recommended for HA)"
  type        = number
  default     = 2

  validation {
    condition     = var.availability_zone_count >= 2 && var.availability_zone_count <= 3
    error_message = "Must use 2 or 3 availability zones."
  }
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = true
}

# Domain and SSL
variable "domain_name" {
  description = "Domain name for the WordPress site"
  type        = string
  default     = "example.com"
}

# Cloudflare Configuration
variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID for DNS management"
  type        = string

  validation {
    condition     = var.cloudflare_zone_id != ""
    error_message = "Cloudflare Zone ID is required."
  }
}

variable "cloudflare_api_token" {
  description = "Cloudflare API Token for authentication (use environment variable TF_VAR_cloudflare_api_token)"
  type        = string
  sensitive   = true

  validation {
    condition     = var.cloudflare_api_token != ""
    error_message = "Cloudflare API Token is required."
  }
}

variable "cloudflare_proxy_enabled" {
  description = "Enable Cloudflare proxy (orange cloud) for DNS records"
  type        = bool
  default     = true
}

# ALB Configuration

variable "alb_enable_logging" {
  description = "Enable ALB access logging to S3"
  type        = bool
  default     = true
}

variable "alb_log_retention_days" {
  description = "Days to retain ALB logs in S3"
  type        = number
  default     = 30
}

# EC2 Instance Configuration
variable "instance_type" {
  description = "EC2 instance type for WordPress"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Size of root EBS volume in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 20 && var.root_volume_size <= 1000
    error_message = "Root volume size must be between 20 and 1000 GB."
  }
}

variable "root_volume_type" {
  description = "EBS volume type for root volume"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1"], var.root_volume_type)
    error_message = "Volume type must be gp2, gp3, or io1."
  }
}

variable "root_volume_iops" {
  description = "IOPS for root volume (gp3 or io1)"
  type        = number
  default     = 3000

  validation {
    condition     = var.root_volume_iops >= 3000 && var.root_volume_iops <= 64000
    error_message = "IOPS must be between 3000 and 64000."
  }
}

variable "root_volume_throughput" {
  description = "Throughput for gp3 volume in MB/s"
  type        = number
  default     = 125

  validation {
    condition     = var.root_volume_throughput >= 125 && var.root_volume_throughput <= 1000
    error_message = "Throughput must be between 125 and 1000 MB/s."
  }
}

# Auto Scaling Group
variable "asg_min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 2

  validation {
    condition     = var.asg_min_size >= 1
    error_message = "Minimum size must be at least 1."
  }
}

variable "asg_max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 6

  validation {
    condition     = var.asg_max_size >= var.asg_min_size
    error_message = "Maximum size must be >= minimum size."
  }
}

variable "asg_desired_capacity" {
  description = "Desired number of instances in ASG"
  type        = number
  default     = 3

  validation {
    condition     = var.asg_desired_capacity >= var.asg_min_size && var.asg_desired_capacity <= var.asg_max_size
    error_message = "Desired capacity must be between min and max size."
  }
}

variable "asg_health_check_type" {
  description = "Health check type for ASG"
  type        = string
  default     = "ELB"

  validation {
    condition     = contains(["EC2", "ELB"], var.asg_health_check_type)
    error_message = "Health check type must be EC2 or ELB."
  }
}

variable "asg_health_check_grace_period" {
  description = "Grace period for health checks in seconds"
  type        = number
  default     = 300
}

variable "asg_default_cooldown" {
  description = "Default cooldown period in seconds"
  type        = number
  default     = 300
}

# EFS Configuration
variable "efs_performance_mode" {
  description = "EFS performance mode"
  type        = string
  default     = "generalPurpose"

  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.efs_performance_mode)
    error_message = "Performance mode must be generalPurpose or maxIO."
  }
}

variable "efs_throughput_mode" {
  description = "EFS throughput mode"
  type        = string
  default     = "bursting"

  validation {
    condition     = contains(["bursting", "provisioned"], var.efs_throughput_mode)
    error_message = "Throughput mode must be bursting or provisioned."
  }
}

variable "efs_provisioned_throughput_mibps" {
  description = "Provisioned throughput in MiBps (only used if throughput_mode is provisioned)"
  type        = number
  default     = 100
}

variable "efs_enable_encryption" {
  description = "Enable encryption at rest for EFS"
  type        = bool
  default     = true
}

# RDS Configuration
variable "rds_engine_version" {
  description = "RDS MySQL engine version"
  type        = string
  default     = "8.0.35"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.small"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 50

  validation {
    condition     = var.rds_allocated_storage >= 20 && var.rds_allocated_storage <= 65536
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
}

variable "rds_storage_type" {
  description = "RDS storage type"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1"], var.rds_storage_type)
    error_message = "Storage type must be gp2, gp3, or io1."
  }
}

variable "rds_iops" {
  description = "RDS IOPS (for gp3 or io1)"
  type        = number
  default     = 3000
}

variable "rds_storage_throughput" {
  description = "RDS throughput for gp3 in MB/s"
  type        = number
  default     = 125
}

variable "rds_backup_retention_days" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 30

  validation {
    condition     = var.rds_backup_retention_days >= 1 && var.rds_backup_retention_days <= 35
    error_message = "Backup retention must be between 1 and 35 days."
  }
}

variable "rds_backup_window" {
  description = "RDS backup window in UTC"
  type        = string
  default     = "03:00-04:00"
}

variable "rds_maintenance_window" {
  description = "RDS maintenance window"
  type        = string
  default     = "mon:04:00-mon:05:00"
}

variable "rds_enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for RDS"
  type        = list(string)
  default     = ["error", "general", "slowquery"]
}

variable "rds_enable_enhanced_monitoring" {
  description = "Enable enhanced monitoring for RDS"
  type        = bool
  default     = true
}

variable "rds_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds"
  type        = number
  default     = 60

  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.rds_monitoring_interval)
    error_message = "Monitoring interval must be 0, 1, 5, 10, 15, 30, or 60 seconds."
  }
}

variable "rds_multi_az" {
  description = "Enable Multi-AZ deployment for RDS"
  type        = bool
  default     = true
}

variable "rds_db_name" {
  description = "Initial WordPress database name"
  type        = string
  default     = "wordpress"

  validation {
    condition     = can(regex("^[a-zA-Z_][a-zA-Z0-9_]*$", var.rds_db_name))
    error_message = "Database name must start with letter or underscore and contain only alphanumeric and underscore characters."
  }
}

variable "rds_db_username" {
  description = "RDS master username"
  type        = string
  default     = "wpadmin"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_]*$", var.rds_db_username))
    error_message = "Username must contain only alphanumeric and underscore characters."
  }
}

variable "rds_db_password" {
  description = "RDS master password (use environment variable TF_VAR_rds_db_password or AWS Secrets Manager)"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!@#"

  validation {
    condition     = length(var.rds_db_password) >= 8 && can(regex("[a-z]", var.rds_db_password)) && can(regex("[A-Z]", var.rds_db_password)) && can(regex("[0-9]", var.rds_db_password))
    error_message = "Password must be at least 8 characters and contain lowercase, uppercase, and numeric characters."
  }
}

# S3 Configuration
variable "s3_enable_versioning" {
  description = "Enable versioning on S3 bucket"
  type        = bool
  default     = true
}

variable "s3_enable_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = true
}

variable "s3_log_retention_days" {
  description = "Days to retain S3 access logs"
  type        = number
  default     = 30
}

variable "s3_enable_encryption" {
  description = "Enable server-side encryption on S3"
  type        = bool
  default     = true
}

# Bootstrap and WordPress Configuration
variable "wordpress_admin_email" {
  description = "WordPress administrator email"
  type        = string
  default     = "admin@example.com"
}

variable "wordpress_site_title" {
  description = "WordPress site title"
  type        = string
  default     = "My WordPress Site"
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for monitoring"
  type        = bool
  default     = true
}

variable "enable_systems_manager_access" {
  description = "Enable AWS Systems Manager Session Manager access to instances"
  type        = bool
  default     = true
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
