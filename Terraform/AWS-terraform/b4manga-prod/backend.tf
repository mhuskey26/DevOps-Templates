# Backend configuration for remote state storage.
# Uncomment and update with your S3 bucket and DynamoDB table details.
#
# Prerequisites:
# 1. S3 bucket with versioning enabled
# 2. DynamoDB table with LockID as the primary key
#
# To enable, uncomment the backend block in main.tf and run:
#   terraform init

# Replace these values with your actual backend configuration
# Example backend configuration (uncomment in main.tf):
#
# backend "s3" {
#   bucket         = "wordpress-asg-terraform-state-256729431040"
#   key            = "wordpress-asg/terraform.tfstate"
#   region         = "us-west-1"
#   encrypt        = true
#   dynamodb_table = "wordpress-asg-terraform-locks"
# }

# After setting up the backend:
# 1. Update the bucket and table names above
# 2. Uncomment the backend block in main.tf
# 3. Run: terraform init
# 4. Terraform will ask to migrate state to S3
