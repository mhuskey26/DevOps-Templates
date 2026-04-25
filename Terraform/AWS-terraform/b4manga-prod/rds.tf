# RDS Subnet Group
resource "aws_db_subnet_group" "wordpress" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = aws_subnet.private_db[*].id

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-db-subnet-group"
    }
  )
}

# RDS Parameter Group
resource "aws_db_parameter_group" "wordpress" {
  name   = "${local.name_prefix}-db-params"
  family = "mysql8.0"

  # WordPress optimized parameters
  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  parameter {
    name  = "max_connections"
    value = "200"
  }

  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-db-params"
    }
  )
}

# RDS Database Instance
resource "aws_db_instance" "wordpress" {
  identifier            = "${local.name_prefix}-db"
  engine                = "mysql"
  engine_version        = var.rds_engine_version
  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  storage_type          = var.rds_storage_type
  storage_encrypted     = true
  iops                  = var.rds_storage_type != "gp2" ? var.rds_iops : null
  storage_throughput    = var.rds_storage_type == "gp3" ? var.rds_storage_throughput : null

  db_name  = var.rds_db_name
  username = var.rds_db_username
  password = var.rds_db_password

  db_subnet_group_name            = aws_db_subnet_group.wordpress.name
  vpc_security_group_ids          = [aws_security_group.rds.id]
  parameter_group_name            = aws_db_parameter_group.wordpress.name
  publicly_accessible             = false
  skip_final_snapshot             = false
  final_snapshot_identifier       = "${local.name_prefix}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  copy_tags_to_snapshot           = true
  backup_retention_period         = var.rds_backup_retention_days
  backup_window                   = var.rds_backup_window
  maintenance_window              = var.rds_maintenance_window
  enabled_cloudwatch_logs_exports = var.rds_enable_cloudwatch_logs
  multi_az                        = var.rds_multi_az
  auto_minor_version_upgrade      = true
  deletion_protection             = var.environment == "prod" ? true : false

  # Enhanced Monitoring
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]
  monitoring_interval             = var.rds_enable_enhanced_monitoring ? var.rds_monitoring_interval : 0
  monitoring_role_arn             = var.rds_enable_enhanced_monitoring ? aws_iam_role.rds_monitoring_role.arn : null

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-db"
    }
  )

  depends_on = [aws_security_group.rds]
}

# RDS CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-rds-cpu"
  alarm_description   = "Alert when RDS CPU exceeds 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_actions       = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress.id
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-rds-connections"
  alarm_description   = "Alert when database connections are high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "150"
  alarm_actions       = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress.id
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-rds-storage"
  alarm_description   = "Alert when free storage space is low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "10737418240" # 10 GB
  alarm_actions       = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress.id
  }

  tags = local.tags
}

# Outputs
output "rds_endpoint" {
  value = aws_db_instance.wordpress.endpoint
}

output "rds_address" {
  value = aws_db_instance.wordpress.address
}

output "rds_port" {
  value = aws_db_instance.wordpress.port
}

output "rds_db_name" {
  value = aws_db_instance.wordpress.db_name
}

output "rds_master_username" {
  value = aws_db_instance.wordpress.username
}

output "rds_resource_id" {
  value = aws_db_instance.wordpress.resource_id
}
