# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = var.environment == "prod" ? true : false
  enable_http2               = true
  enable_cross_zone_load_balancing = true

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-alb"
    }
  )
}

# ALB Access Logs
resource "aws_s3_bucket" "alb_logs" {
  count  = var.alb_enable_logging ? 1 : 0
  bucket = "${local.name_prefix}-alb-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-alb-logs"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  count  = var.alb_enable_logging ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  count  = var.alb_enable_logging ? 1 : 0
  bucket = aws_s3_bucket.alb_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# ALB logging configuration
resource "aws_lb_logging" "main" {
  count            = var.alb_enable_logging ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  bucket           = aws_s3_bucket.alb_logs[0].id
  enabled          = true
  prefix           = "alb"
}

# ALB Target Group
resource "aws_lb_target_group" "wordpress" {
  name                 = "${local.name_prefix}-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.main.id
  target_type          = "instance"
  deregistration_delay = 30

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    path                = "/healthcheck.php"
    matcher             = "200"
    port                = "80"
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-tg"
    }
  )
}

# ALB HTTP Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress.arn
  }
}

# Note: HTTPS is handled by Cloudflare at the edge
# ALB listens only on HTTP (port 80)
# Cloudflare manages SSL/TLS certificates and redirects HTTP to HTTPS

# CloudWatch Alarms for ALB
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-alb-unhealthy-hosts"
  alarm_description   = "Alert when ALB has unhealthy targets"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
    TargetGroup  = aws_lb_target_group.wordpress.arn_suffix
  }

  tags = local.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${local.name_prefix}-alb-response-time"
  alarm_description   = "Alert when ALB target response time is high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"  # 1 second
  alarm_actions       = []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = local.tags
}

# Outputs
output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_zone_id" {
  value = aws_lb.main.zone_id
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.wordpress.arn
}

output "alb_target_group_name" {
  value = aws_lb_target_group.wordpress.name
}
