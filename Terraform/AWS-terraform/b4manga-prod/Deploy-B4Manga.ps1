# B4 Manga Production Deployment Script (PowerShell)
# Usage: .\Deploy-B4Manga.ps1 -Action plan|apply|destroy

param(
    [ValidateSet('plan', 'apply', 'destroy', 'init', 'validate', 'output')]
    [string]$Action = 'plan'
)

$ErrorActionPreference = 'Stop'

# B4 Manga Configuration
$CloudflareApiToken = '85f70c2faba1eac83a2c9f0bbbf653d8c1b63'
$Domain = 'b4manga.com'
$AwsRegion = 'us-west-1'

# Color definitions
function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "╔" + ("=" * 60) + "╗" -ForegroundColor Cyan
    Write-Host "║  $Message" -ForegroundColor Cyan
    Write-Host "╚" + ("=" * 60) + "╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Section {
    param([string]$Message)
    Write-Host "▶ $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ Error: $Message" -ForegroundColor Red
    exit 1
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ Warning: $Message" -ForegroundColor Yellow
}

# Check prerequisites
function Test-Prerequisites {
    Write-Section "Checking prerequisites..."
    
    # Check Terraform
    $terraform = Get-Command terraform -ErrorAction SilentlyContinue
    if (-not $terraform) {
        Write-Error "Terraform not found. Please install Terraform >= 1.0"
    }
    Write-Success "Terraform installed"
    
    # Check AWS CLI
    $awscli = Get-Command aws -ErrorAction SilentlyContinue
    if (-not $awscli) {
        Write-Error "AWS CLI not found. Please install AWS CLI v2"
    }
    Write-Success "AWS CLI installed"
    
    # Check AWS credentials
    try {
        $account = aws sts get-caller-identity --query Account --output text
        Write-Success "AWS account: $account"
    }
    catch {
        Write-Error "AWS credentials not configured. Run 'aws configure' first."
    }
}

# Setup environment variables
function Set-Environment {
    Write-Section "Setting up environment variables..."
    
    # Set Cloudflare API Token
    $env:TF_VAR_cloudflare_api_token = $CloudflareApiToken
    Write-Success "Cloudflare API Token configured"
    
    # Check if RDS password is set
    if (-not $env:TF_VAR_rds_db_password) {
        Write-Warning "RDS password not set in environment"
        Write-Host "Please set before deployment:"
        Write-Host "  `$env:TF_VAR_rds_db_password = 'YourSecurePassword123!@#'"
        $rdsPass = Read-Host "Enter RDS password (or Ctrl+C to cancel)"
        if ([string]::IsNullOrEmpty($rdsPass)) {
            Write-Error "RDS password is required"
        }
        $env:TF_VAR_rds_db_password = $rdsPass
    }
    Write-Success "RDS password configured"
    
    # Check Cloudflare Zone ID
    $tfvars = Get-Content terraform.tfvars
    if ($tfvars -match 'cloudflare_zone_id = ""') {
        Write-Warning "Cloudflare Zone ID not set in terraform.tfvars"
        Write-Host "Get your Zone ID:"
        Write-Host "  1. Go to https://dash.cloudflare.com"
        Write-Host "  2. Select domain: b4manga.com"
        Write-Host "  3. Settings → General → Zone ID"
        $zoneId = Read-Host "Enter Cloudflare Zone ID"
        if ([string]::IsNullOrEmpty($zoneId)) {
            Write-Error "Zone ID is required"
        }
        (Get-Content terraform.tfvars) -replace 'cloudflare_zone_id = ""', "cloudflare_zone_id = ""$zoneId""" | Set-Content terraform.tfvars
        Write-Success "Updated Cloudflare Zone ID in terraform.tfvars"
    }
    else {
        Write-Success "Cloudflare Zone ID is configured"
    }
}

# Initialize Terraform
function Invoke-TerraformInit {
    Write-Section "Initializing Terraform..."
    terraform init
    Write-Success "Terraform initialized"
}

# Validate Terraform
function Invoke-TerraformValidate {
    Write-Section "Validating Terraform configuration..."
    terraform validate
    Write-Success "Terraform configuration is valid"
}

# Plan deployment
function Invoke-TerraformPlan {
    Write-Section "Creating Terraform plan..."
    terraform plan -out=tfplan -compact-warnings
    Write-Success "Plan created: tfplan"
    Write-Host ""
    Write-Host "Review the plan above. To apply, run:" -ForegroundColor Yellow
    Write-Host "  .\Deploy-B4Manga.ps1 -Action apply"
}

# Apply deployment
function Invoke-TerraformApply {
    Write-Section "Applying Terraform configuration..."
    
    if (-not (Test-Path tfplan)) {
        Write-Error "No plan file found. Run '.\Deploy-B4Manga.ps1 -Action plan' first"
    }
    
    Write-Warning "This will create AWS resources and incur costs!"
    $confirm = Read-Host "Type 'yes' to proceed with deployment"
    if ($confirm -ne 'yes') {
        Write-Error "Deployment cancelled"
    }
    
    terraform apply tfplan
    
    Write-Success "Terraform apply completed"
    Show-Outputs
}

# Destroy deployment
function Invoke-TerraformDestroy {
    Write-Section "Destroying Terraform resources..."
    
    Write-Warning "This will DELETE all resources including the database!"
    Write-Warning "This action cannot be undone!"
    $confirm = Read-Host "Type 'yes' to confirm destruction"
    if ($confirm -ne 'yes') {
        Write-Error "Destruction cancelled"
    }
    
    # Create final backup
    Write-Section "Creating final RDS backup before destruction..."
    $dbIdentifier = 'b4manga-prod-db'
    $snapshotId = "$dbIdentifier-final-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    try {
        $dbExists = aws rds describe-db-instances --db-instance-identifier $dbIdentifier --region $AwsRegion 2>$null
        if ($dbExists) {
            Write-Section "Backing up database to snapshot: $snapshotId"
            aws rds create-db-snapshot `
                --db-instance-identifier $dbIdentifier `
                --db-snapshot-identifier $snapshotId `
                --region $AwsRegion
            Write-Success "Database backup initiated: $snapshotId"
        }
    }
    catch {
        Write-Warning "Could not backup database (may not exist yet)"
    }
    
    # Destroy infrastructure
    terraform destroy
    
    # Clean up
    Write-Section "Cleaning up Terraform state..."
    Remove-Item -Path .terraform -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path .terraform.lock.hcl -Force -ErrorAction SilentlyContinue
    Remove-Item -Path tfplan -Force -ErrorAction SilentlyContinue
    
    Write-Success "Resources destroyed and state cleaned"
}

# Show outputs
function Show-Outputs {
    Write-Section "Infrastructure outputs:"
    
    try {
        $outputs = terraform output -json | ConvertFrom-Json
        
        Write-Host ""
        Write-Host "ALB DNS Name:" -ForegroundColor Yellow
        Write-Host $outputs.alb_dns_name.value
        
        Write-Host ""
        Write-Host "RDS Endpoint:" -ForegroundColor Yellow
        Write-Host $outputs.rds_address.value
        
        Write-Host ""
        Write-Host "EFS ID:" -ForegroundColor Yellow
        Write-Host $outputs.efs_id.value
        
        Write-Host ""
        Write-Host "S3 Bucket:" -ForegroundColor Yellow
        Write-Host $outputs.s3_bucket_name.value
        
        Write-Host ""
        Write-Section "Next steps:"
        Write-Host "1. Configure Cloudflare DNS (see B4MANGA-SETUP.md)"
        Write-Host "2. Access WordPress: https://$Domain"
        Write-Host "3. Complete WordPress setup wizard"
        Write-Host "4. Install plugins and configure site"
    }
    catch {
        Write-Warning "Could not retrieve outputs"
    }
}

# Main
function Main {
    Write-Header "B4 Manga Production - WordPress ASG Infrastructure`n                     Terraform Deployment"
    
    switch ($Action) {
        'plan' {
            Test-Prerequisites
            Set-Environment
            Invoke-TerraformInit
            Invoke-TerraformValidate
            Invoke-TerraformPlan
        }
        'apply' {
            Test-Prerequisites
            Set-Environment
            Invoke-TerraformInit
            Invoke-TerraformApply
        }
        'destroy' {
            Test-Prerequisites
            Invoke-TerraformDestroy
        }
        'init' {
            Test-Prerequisites
            Invoke-TerraformInit
        }
        'validate' {
            Test-Prerequisites
            Invoke-TerraformValidate
        }
        'output' {
            Show-Outputs
        }
        default {
            Write-Host "Usage: .\Deploy-B4Manga.ps1 -Action {plan|apply|destroy|init|validate|output}"
            Write-Host ""
            Write-Host "Actions:"
            Write-Host "  plan     - Create and display Terraform plan (default)"
            Write-Host "  apply    - Apply the Terraform plan"
            Write-Host "  destroy  - Destroy all resources (with backup)"
            Write-Host "  init     - Initialize Terraform"
            Write-Host "  validate - Validate Terraform configuration"
            Write-Host "  output   - Display infrastructure outputs"
            exit 1
        }
    }
}

Main
