# EFS File System
resource "aws_efs_file_system" "wordpress" {
  performance_mode = var.efs_performance_mode
  throughput_mode  = var.efs_throughput_mode
  encrypted        = var.efs_enable_encryption

  # Only set provisioned throughput if in provisioned mode
  provisioned_throughput_in_mibps = var.efs_throughput_mode == "provisioned" ? var.efs_provisioned_throughput_mibps : null

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-efs"
    }
  )
}

# EFS Mount Targets (one per AZ)
resource "aws_efs_mount_target" "wordpress" {
  count           = var.availability_zone_count
  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = aws_subnet.private_app[count.index].id
  security_groups = [aws_security_group.efs.id]
}

# EFS Access Point for WordPress
resource "aws_efs_access_point" "wordpress" {
  file_system_id = aws_efs_file_system.wordpress.id
  root_directory {
    path = "/wordpress"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "755"
    }
  }

  posix_user {
    gid = 48  # Apache group (www-data)
    uid = 48  # Apache user (www-data)
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-efs-ap"
    }
  )
}

# EFS Backup Policy
resource "aws_efs_backup_policy" "wordpress" {
  file_system_id = aws_efs_file_system.wordpress.id

  backup_policy {
    status = "ENABLED"
  }
}

# Outputs
output "efs_id" {
  value = aws_efs_file_system.wordpress.id
}

output "efs_arn" {
  value = aws_efs_file_system.wordpress.arn
}

output "efs_dns_name" {
  value = aws_efs_file_system.wordpress.dns_name
}

output "efs_mount_target_ids" {
  value = aws_efs_mount_target.wordpress[*].id
}

output "efs_access_point_id" {
  value = aws_efs_access_point.wordpress.id
}
