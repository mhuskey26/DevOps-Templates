# Get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# User data script for bootstrapping WordPress
locals {
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    efs_dns_name            = aws_efs_file_system.wordpress.dns_name
    site_domain             = var.domain_name
    web_root                = "/var/www/html"
    efs_mount_point         = "/mnt/efs"
    shared_wp_content       = "/mnt/efs/wp-content"
    wp_db_name              = var.rds_db_name
    wp_db_user              = var.rds_db_username
    wp_db_password          = var.rds_db_password
    wp_db_host              = aws_db_instance.wordpress.address
    wordpress_admin_email   = var.wordpress_admin_email
    wordpress_site_title    = var.wordpress_site_title
  }))
}

# EC2 Launch Template
resource "aws_launch_template" "wordpress" {
  name_prefix   = "${local.name_prefix}-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = var.root_volume_type
      iops                  = var.root_volume_type != "gp2" ? var.root_volume_iops : null
      throughput            = var.root_volume_type == "gp3" ? var.root_volume_throughput : null
      delete_on_termination = true
      encrypted             = true
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  monitoring {
    enabled = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 only
    http_put_response_hop_limit = 1
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2.id]
    delete_on_termination       = true
  }

  user_data = local.user_data

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.tags,
      {
        Name = "${local.name_prefix}-instance"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      local.tags,
      {
        Name = "${local.name_prefix}-volume"
      }
    )
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Outputs
output "launch_template_id" {
  value = aws_launch_template.wordpress.id
}

output "launch_template_latest_version" {
  value = aws_launch_template.wordpress.latest_version_number
}

output "ami_id" {
  value = data.aws_ami.amazon_linux_2023.id
}

output "ami_name" {
  value = data.aws_ami.amazon_linux_2023.name
}
