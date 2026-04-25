# Auto Scaling Group
resource "aws_autoscaling_group" "wordpress" {
  name                = "${local.name_prefix}-asg"
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.asg_desired_capacity
  health_check_type   = var.asg_health_check_type
  health_check_grace_period = var.asg_health_check_grace_period
  default_cooldown    = var.asg_default_cooldown
  vpc_zone_identifier = aws_subnet.private_app[*].id
  target_group_arns   = [aws_lb_target_group.wordpress.arn]
  termination_policies = [
    "OldestInstance",
    "Default"
  ]

  launch_template {
    id      = aws_launch_template.wordpress.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-asg-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      desired_capacity
    ]
  }

  depends_on = [
    aws_db_instance.wordpress,
    aws_efs_mount_target.wordpress
  ]
}

# Scaling Policy - Scale Up (CPU > 70%)
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${local.name_prefix}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.wordpress.name
}

resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "${local.name_prefix}-scale-up-alarm"
  alarm_description   = "Trigger scale up when CPU > 70%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress.name
  }
}

# Scaling Policy - Scale Down (CPU < 30%)
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${local.name_prefix}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.wordpress.name
}

resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "${local.name_prefix}-scale-down-alarm"
  alarm_description   = "Trigger scale down when CPU < 30%"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.wordpress.name
  }
}

# Scaling Policy - Scale based on ALB Request Count
resource "aws_autoscaling_policy" "scale_on_request_count" {
  name                   = "${local.name_prefix}-scale-requests"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.wordpress.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
    }

    target_value = 1000.0  # Scale when requests per instance > 1000
  }
}

# CloudWatch Alarms for ASG
resource "aws_cloudwatch_metric_alarm" "asg_desired_vs_running" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-asg-capacity-mismatch"
  alarm_description   = "Alert when desired capacity doesn't match running instances"
  comparison_operator = "NotEqualToComparisonMetric"
  evaluation_periods  = "5"
  threshold_metric_id = "e1"
  alarm_actions       = []

  metric_query {
    id          = "e1"
    expression  = "IF(desired - running != 0, 1, 0)"
    label       = "Mismatch"
    return_data = true
  }

  metric_query {
    id          = "desired"
    return_data = false
    metric {
      metric_name = "GroupDesiredCapacity"
      namespace   = "AWS/AutoScaling"
      period      = "300"
      stat        = "Average"

      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.wordpress.name
      }
    }
  }

  metric_query {
    id          = "running"
    return_data = false
    metric {
      metric_name = "GroupInServiceInstances"
      namespace   = "AWS/AutoScaling"
      period      = "300"
      stat        = "Average"

      dimensions = {
        AutoScalingGroupName = aws_autoscaling_group.wordpress.name
      }
    }
  }

  tags = local.tags
}

# Outputs
output "asg_name" {
  value = aws_autoscaling_group.wordpress.name
}

output "asg_arn" {
  value = aws_autoscaling_group.wordpress.arn
}

output "asg_min_size" {
  value = aws_autoscaling_group.wordpress.min_size
}

output "asg_max_size" {
  value = aws_autoscaling_group.wordpress.max_size
}

output "asg_desired_capacity" {
  value = aws_autoscaling_group.wordpress.desired_capacity
}
