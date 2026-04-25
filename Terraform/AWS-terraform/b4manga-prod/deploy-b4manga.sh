#!/bin/bash
# B4 Manga Production Deployment Script
# Usage: ./deploy-b4manga.sh [plan|apply|destroy]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# B4 Manga Configuration
CLOUDFLARE_API_TOKEN="85f70c2faba1eac83a2c9f0bbbf653d8c1b63"
DOMAIN="b4manga.com"
AWS_REGION="us-west-1"

# Print banner
print_banner() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║      B4 Manga Production - WordPress ASG Infrastructure    ║"
    echo "║                   Terraform Deployment                      ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print section headers
print_section() {
    echo -e "\n${BLUE}▶ $1${NC}"
}

# Print error
print_error() {
    echo -e "${RED}✗ Error: $1${NC}"
}

# Print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print warning
print_warning() {
    echo -e "${YELLOW}⚠ Warning: $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_section "Checking prerequisites..."
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform not found. Please install Terraform >= 1.0"
        exit 1
    fi
    print_success "Terraform installed: $(terraform version -json | jq -r .terraform_version)"
    
    # Check AWS CLI
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI not found. Please install AWS CLI v2"
        exit 1
    fi
    print_success "AWS CLI installed"
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured"
        exit 1
    fi
    AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    print_success "AWS account: $AWS_ACCOUNT"
    
    # Check jq (for JSON parsing)
    if ! command -v jq &> /dev/null; then
        print_warning "jq not found. Some output formatting will be limited."
    fi
}

# Setup environment variables
setup_environment() {
    print_section "Setting up environment variables..."
    
    # Set Cloudflare API Token
    export TF_VAR_cloudflare_api_token="$CLOUDFLARE_API_TOKEN"
    print_success "Cloudflare API Token configured"
    
    # Check if RDS password is set
    if [ -z "${TF_VAR_rds_db_password:-}" ]; then
        print_warning "RDS password not set in environment"
        echo -e "${YELLOW}Please set before deployment:${NC}"
        echo "  export TF_VAR_rds_db_password='YourSecurePassword123!@#'"
        read -p "Enter RDS password (or press Ctrl+C to cancel): " RDS_PASS
        if [ -z "$RDS_PASS" ]; then
            print_error "RDS password is required"
            exit 1
        fi
        export TF_VAR_rds_db_password="$RDS_PASS"
    fi
    print_success "RDS password configured"
    
    # Check Cloudflare Zone ID
    if grep -q 'cloudflare_zone_id = ""' terraform.tfvars; then
        print_warning "Cloudflare Zone ID not set in terraform.tfvars"
        echo -e "${YELLOW}Get your Zone ID:${NC}"
        echo "  1. Go to https://dash.cloudflare.com"
        echo "  2. Select domain: b4manga.com"
        echo "  3. Settings → General → Zone ID"
        read -p "Enter Cloudflare Zone ID: " ZONE_ID
        if [ -z "$ZONE_ID" ]; then
            print_error "Zone ID is required"
            exit 1
        fi
        # Update terraform.tfvars
        sed -i.bak "s/cloudflare_zone_id = \"\"/cloudflare_zone_id = \"$ZONE_ID\"/" terraform.tfvars
        print_success "Updated Cloudflare Zone ID in terraform.tfvars"
    else
        print_success "Cloudflare Zone ID is configured"
    fi
}

# Initialize Terraform
init_terraform() {
    print_section "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized"
}

# Validate Terraform
validate_terraform() {
    print_section "Validating Terraform configuration..."
    terraform validate
    print_success "Terraform configuration is valid"
}

# Plan deployment
plan_deployment() {
    print_section "Creating Terraform plan..."
    terraform plan -out=tfplan -compact-warnings
    print_success "Plan created: tfplan"
    echo -e "\n${YELLOW}Review the plan above. To apply, run:${NC}"
    echo "  $0 apply"
}

# Apply deployment
apply_deployment() {
    print_section "Applying Terraform configuration..."
    
    if [ ! -f tfplan ]; then
        print_error "No plan file found. Run '$0 plan' first"
        exit 1
    fi
    
    print_warning "This will create AWS resources and incur costs!"
    read -p "Type 'yes' to proceed with deployment: " confirm
    if [ "$confirm" != "yes" ]; then
        print_error "Deployment cancelled"
        exit 1
    fi
    
    terraform apply tfplan
    
    print_success "Terraform apply completed"
    print_outputs
}

# Destroy deployment
destroy_deployment() {
    print_section "Destroying Terraform resources..."
    
    print_warning "This will DELETE all resources including the database!"
    print_warning "This action cannot be undone!"
    read -p "Type 'yes' to confirm destruction: " confirm
    if [ "$confirm" != "yes" ]; then
        print_error "Destruction cancelled"
        exit 1
    fi
    
    # Create final backup
    print_section "Creating final RDS backup before destruction..."
    DB_IDENTIFIER="b4manga-prod-db"
    SNAPSHOT_ID="$DB_IDENTIFIER-final-backup-$(date +%Y%m%d-%H%M%S)"
    
    if aws rds describe-db-instances --db-instance-identifier "$DB_IDENTIFIER" &> /dev/null 2>&1; then
        print_section "Backing up database to snapshot: $SNAPSHOT_ID"
        aws rds create-db-snapshot \
            --db-instance-identifier "$DB_IDENTIFIER" \
            --db-snapshot-identifier "$SNAPSHOT_ID" \
            --region "$AWS_REGION"
        print_success "Database backup initiated: $SNAPSHOT_ID"
    fi
    
    # Destroy infrastructure
    terraform destroy
    
    # Clean up
    print_section "Cleaning up Terraform state..."
    rm -rf .terraform/
    rm -f .terraform.lock.hcl
    rm -f tfplan
    
    print_success "Resources destroyed and state cleaned"
}

# Print outputs
print_outputs() {
    print_section "Infrastructure outputs:"
    
    if terraform output -json &> /dev/null; then
        echo ""
        echo "ALB DNS Name:"
        terraform output -raw alb_dns_name
        echo ""
        echo "RDS Endpoint:"
        terraform output -raw rds_address
        echo ""
        echo "EFS ID:"
        terraform output -raw efs_id
        echo ""
        echo "S3 Bucket:"
        terraform output -raw s3_bucket_name
        echo ""
        
        print_section "Next steps:"
        echo "1. Configure Cloudflare DNS (see B4MANGA-SETUP.md)"
        echo "2. Access WordPress: https://$DOMAIN"
        echo "3. Complete WordPress setup wizard"
        echo "4. Install plugins and configure site"
    fi
}

# Main
main() {
    print_banner
    
    ACTION="${1:-plan}"
    
    case "$ACTION" in
        plan)
            check_prerequisites
            setup_environment
            init_terraform
            validate_terraform
            plan_deployment
            ;;
        apply)
            check_prerequisites
            setup_environment
            init_terraform
            apply_deployment
            ;;
        destroy)
            check_prerequisites
            destroy_deployment
            ;;
        init)
            check_prerequisites
            init_terraform
            ;;
        validate)
            check_prerequisites
            validate_terraform
            ;;
        output)
            print_outputs
            ;;
        *)
            echo "Usage: $0 {plan|apply|destroy|init|validate|output}"
            echo ""
            echo "Commands:"
            echo "  plan     - Create and display Terraform plan (default)"
            echo "  apply    - Apply the Terraform plan"
            echo "  destroy  - Destroy all resources (with backup)"
            echo "  init     - Initialize Terraform"
            echo "  validate - Validate Terraform configuration"
            echo "  output   - Display infrastructure outputs"
            exit 1
            ;;
    esac
}

main "$@"
