# S3 Bucket for WordPress backups, logs, and media
resource "aws_s3_bucket" "wordpress" {
  bucket = "${local.name_prefix}-bucket-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-bucket"
    }
  )
}

# Block public access
resource "aws_s3_bucket_public_access_block" "wordpress" {
  bucket = aws_s3_bucket.wordpress.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "wordpress" {
  bucket = aws_s3_bucket.wordpress.id

  versioning_configuration {
    status = var.s3_enable_versioning ? "Enabled" : "Suspended"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "wordpress" {
  bucket = aws_s3_bucket.wordpress.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket logging
resource "aws_s3_bucket_logging" "wordpress" {
  count          = var.s3_enable_logging ? 1 : 0
  bucket         = aws_s3_bucket.wordpress.id
  target_bucket  = aws_s3_bucket.wordpress_logs[0].id
  target_prefix  = "logs/s3-access/"
}

# S3 bucket for S3 access logs
resource "aws_s3_bucket" "wordpress_logs" {
  count  = var.s3_enable_logging ? 1 : 0
  bucket = "${local.name_prefix}-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-logs-bucket"
    }
  )
}

# Block public access on logs bucket
resource "aws_s3_bucket_public_access_block" "wordpress_logs" {
  count  = var.s3_enable_logging ? 1 : 0
  bucket = aws_s3_bucket.wordpress_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning on logs bucket
resource "aws_s3_bucket_versioning" "wordpress_logs" {
  count  = var.s3_enable_logging ? 1 : 0
  bucket = aws_s3_bucket.wordpress_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle policy for logs bucket
resource "aws_s3_bucket_lifecycle_configuration" "wordpress_logs" {
  count  = var.s3_enable_logging ? 1 : 0
  bucket = aws_s3_bucket.wordpress_logs[0].id

  rule {
    id     = "delete-old-logs"
    status = "Enabled"

    expiration {
      days = var.s3_log_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

# Lifecycle policy for main bucket
resource "aws_s3_bucket_lifecycle_configuration" "wordpress" {
  bucket = aws_s3_bucket.wordpress.id

  rule {
    id     = "cleanup-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }

  rule {
    id     = "cleanup-incomplete-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Bucket policy for CloudFront (when needed)
# Uncomment and customize for CloudFront distribution
# resource "aws_s3_bucket_policy" "wordpress_cloudfront" {
#   bucket = aws_s3_bucket.wordpress.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity <OAI_ID>"
#         }
#         Action   = "s3:GetObject"
#         Resource = "${aws_s3_bucket.wordpress.arn}/*"
#       }
#     ]
#   })
# }

# Outputs
output "s3_bucket_name" {
  value = aws_s3_bucket.wordpress.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.wordpress.arn
}

output "s3_bucket_region" {
  value = aws_s3_bucket.wordpress.region
}

output "s3_logs_bucket_name" {
  value = var.s3_enable_logging ? aws_s3_bucket.wordpress_logs[0].id : null
}
