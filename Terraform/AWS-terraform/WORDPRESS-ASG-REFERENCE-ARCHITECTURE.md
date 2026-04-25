# AWS WordPress Reference Architecture

This document defines the target architecture for a highly available WordPress environment on AWS that will later be implemented in Terraform.

## Goal

Run WordPress on EC2 behind an Application Load Balancer with Auto Scaling, while allowing:
- high availability across Availability Zones
- fast horizontal scaling
- plugin and theme updates
- image and media uploads
- persistent shared WordPress content

## Recommended Storage Model

- WordPress core code: local to each EC2 instance and deployed as part of the instance bootstrap or baked AMI
- Database: Amazon RDS or Amazon Aurora MySQL
- Shared WordPress content: Amazon EFS
- Media offload and backups: Amazon S3

Recommended EFS layout:
- `/wp-content/uploads`
- `/wp-content/plugins`
- `/wp-content/themes`

This allows plugin and theme updates from wp-admin to be visible across all instances.

## Core AWS Components

- VPC across at least 2 Availability Zones
- Public subnets for ALB
- Private subnets for EC2 application servers
- Private subnets for RDS
- Application Load Balancer
- Auto Scaling Group with Launch Template
- Amazon EFS with mount targets in each application subnet AZ
- Amazon RDS or Aurora MySQL
- S3 bucket for media offload, backups, and deployment artifacts
- IAM role for EC2
- Security groups for ALB, EC2, EFS, and RDS
- Route 53 DNS record for the site
- ACM certificate for HTTPS on the ALB

## Request Flow

1. User accesses the WordPress site through Route 53.
2. Route 53 points to the ALB.
3. ALB forwards requests to EC2 instances in the Auto Scaling Group.
4. WordPress code runs locally on each instance.
5. Shared `wp-content` is served from EFS.
6. Database operations go to RDS or Aurora.
7. Media can optionally be offloaded to S3 through a WordPress plugin and served by CloudFront.

## Security Group Model

- ALB security group:
  - allow `80` from the internet
  - allow `443` from the internet
- EC2 security group:
  - allow `80` from ALB security group
  - allow `443` from ALB security group if end-to-end TLS is needed
  - allow `22` only from admin IPs or through SSM instead of SSH
- EFS security group:
  - allow `2049` from EC2 security group
- RDS security group:
  - allow `3306` from EC2 security group

## EC2 Bootstrap Expectations

The EC2 bootstrap script should:
- install Apache and PHP on Amazon Linux 2023
- mount EFS at boot
- deploy or download WordPress core locally
- map shared `wp-content` to EFS
- write `wp-config.php` using external database settings
- expose a lightweight health check endpoint for the ALB

## Operational Guidance

- Use an immutable deployment model for WordPress core whenever possible.
- Keep `wp-content` on EFS for shared mutable state.
- Use S3 for backups and optional media offload instead of mounting S3 as a live filesystem.
- Disable default WordPress cron and replace it with a real cron or scheduled task.
- Add Redis or ElastiCache later for object caching if needed.
- Use AWS Systems Manager instead of direct SSH where possible.

## Terraform Build Targets

The future Terraform deployment should be split into modules or logical sections for:
- networking
- security groups
- ALB and target groups
- launch template and Auto Scaling Group
- EFS
- RDS
- IAM roles and instance profile
- S3 bucket
- Route 53 and ACM

## Inputs To Prepare Before Terraform

- AWS region
- VPC CIDR and subnet CIDRs
- domain name
- ACM certificate strategy
- EC2 instance type
- AMI or bootstrap strategy
- RDS engine and sizing
- EFS performance and throughput mode
- WordPress database name, username, and password secret source
- S3 bucket naming strategy

## Recommended Next Terraform Step

Start with the network, security groups, EFS, and RDS layers first. After that, create the launch template and Auto Scaling Group around the bootstrap script.