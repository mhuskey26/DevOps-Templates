# AWS Python Automation Templates

A comprehensive collection of production-ready Python automation templates for AWS services. Each template is designed as a standalone module with configurable environment variables and can run as AWS Lambda functions, standalone scripts, or be imported as modules.

## Overview

This collection provides templates for automating common AWS tasks across multiple services:

| Template | Purpose | Supported Actions |
|----------|---------|-------------------|
| **CopyfromS3.py** | S3 object copying | Copy objects from source to target bucket |
| **AWS_S3_Backup_Manager.py** | S3 backup management | Backup, sync, versioning, cleanup |
| **AWS_EC2_Instance_Manager.py** | EC2 lifecycle | Start, stop, terminate, reboot, status |
| **AWS_RDS_Snapshot_Manager.py** | RDS snapshots | Create, list, cleanup, cross-region copy |
| **AWS_CloudWatch_Logs_Analyzer.py** | Log analysis | Search, metrics, errors, Insights queries |
| **AWS_DynamoDB_Table_Manager.py** | DynamoDB operations | Backup, restore, scale, PITR, status |
| **AWS_IAM_User_Manager.py** | IAM user admin | Create, delete, audit, rotate keys, MFA |
| **AWS_SNS_SQS_Message_Processor.py** | Message services | Publish, subscribe, queue processing, DLQ |
| **AWS_Lambda_Function_Manager.py** | Lambda management | Deploy, invoke, version, alias management |

## Features

✅ **Modern Python 3 Standards**
- Type hints for all function parameters and returns
- Proper error handling with ClientError catching
- Structured logging with context information
- Module-level configuration variables
- Environment variable support

✅ **Production-Ready**
- Error handling with detailed logging
- Structured JSON responses
- Works as Lambda functions or standalone scripts
- Retry logic and timeout handling
- Resource cleanup and validation

✅ **Flexible Deployment**
- AWS Lambda compatible (with `lambda_handler` entry point)
- Standalone CLI usage (`if __name__ == "__main__"`)
- Importable as Python modules
- Easy to integrate with CI/CD pipelines

✅ **Comprehensive Logging**
- INFO level for operations
- ERROR level for failures
- DEBUG support for troubleshooting
- CloudWatch compatible logging

## Configuration

### Environment Variables

Each template uses environment variables for configuration. Set them before running:

```bash
# Example for S3 Backup Manager
export SOURCE_BUCKET="my-source-bucket"
export BACKUP_BUCKET="my-backup-bucket"
export RETENTION_DAYS="30"
export AWS_REGION="us-east-1"
```

### Common Configuration Pattern

All templates follow this configuration structure:

```python
# Module-level configuration
VARIABLE_NAME = os.environ.get("VARIABLE_NAME", "default-value")
TYPE_VAR = type(os.environ.get("TYPE_VAR", "default"))
```

## Template Reference

### 1. AWS_S3_Backup_Manager.py

**Purpose**: Automated S3 bucket backup, sync, versioning, and cleanup

**Configuration Variables**:
- `SOURCE_BUCKET`: Source bucket name
- `BACKUP_BUCKET`: Destination backup bucket
- `PREFIX`: S3 prefix to process (optional)
- `ENABLE_VERSIONING`: Enable S3 versioning (default: true)
- `DELETE_OLDER_THAN_DAYS`: Retention period (default: 90)
- `MAX_OBJECTS`: Max objects to process per run (default: 0 = unlimited)

**Supported Actions**:
- `backup` - Full backup workflow (versioning + sync + cleanup)
- `sync` - Copy new/changed objects
- `cleanup` - Delete old objects
- `status` - Get backup statistics

**Usage**:
```bash
# Backup workflow
python AWS_S3_Backup_Manager.py
export ACTION="sync"; python AWS_S3_Backup_Manager.py

# As Lambda
export SOURCE_BUCKET="source"; export BACKUP_BUCKET="backup"
aws lambda invoke --function-name s3-backup --payload '{}' response.json
```

---

### 2. AWS_EC2_Instance_Manager.py

**Purpose**: EC2 instance lifecycle management with tag-based filtering

**Configuration Variables**:
- `AWS_REGION`: AWS region (default: us-east-1)
- `FILTER_TAG_KEY`: Tag key for filtering (default: Environment)
- `FILTER_TAG_VALUE`: Tag value to match (default: dev)
- `ACTION`: Operation to perform (default: status)
- `MAX_INSTANCES`: Max instances to process (default: 0 = unlimited)
- `FORCE_TERMINATE`: Skip stopping before terminating (default: false)

**Supported Actions**:
- `start` - Start stopped instances
- `stop` - Stop running instances
- `terminate` - Gracefully terminate (stop then delete)
- `reboot` - Reboot running instances
- `status` - Report instance status

**Usage**:
```bash
# Stop all dev environment instances
export ACTION="stop" FILTER_TAG_VALUE="dev"
python AWS_EC2_Instance_Manager.py

# Start all prod instances
export ACTION="start" FILTER_TAG_VALUE="prod"
python AWS_EC2_Instance_Manager.py

# Check status
export ACTION="status" python AWS_EC2_Instance_Manager.py
```

---

### 3. AWS_RDS_Snapshot_Manager.py

**Purpose**: RDS database snapshot management and cross-region backup

**Configuration Variables**:
- `DB_INSTANCE_ID`: RDS database identifier
- `PRIMARY_REGION`: Primary AWS region (default: us-east-1)
- `BACKUP_REGION`: Backup region for cross-region copy
- `RETENTION_DAYS`: Snapshot retention (default: 30)
- `CROSS_REGION_COPY`: Enable cross-region copy (default: true)
- `ACTION`: Operation (default: create)

**Supported Actions**:
- `create` - Create on-demand snapshot
- `list` - List available snapshots
- `cleanup` - Delete old snapshots
- `copy` - Copy latest snapshot to backup region
- `restore` - Restore from snapshot

**Usage**:
```bash
# Daily snapshot
export DB_INSTANCE_ID="prod-db" ACTION="create"
python AWS_RDS_Snapshot_Manager.py

# List snapshots
export ACTION="list"
python AWS_RDS_Snapshot_Manager.py

# Cleanup old snapshots
export ACTION="cleanup" RETENTION_DAYS="30"
python AWS_RDS_Snapshot_Manager.py
```

---

### 4. AWS_CloudWatch_Logs_Analyzer.py

**Purpose**: CloudWatch log analysis, error detection, and metrics extraction

**Configuration Variables**:
- `LOG_GROUP_NAME`: CloudWatch log group name
- `LOOKBACK_MINUTES`: Analysis period (default: 60)
- `SEARCH_PATTERN`: Filter pattern for search (default: errors)
- `ACTION`: Operation (default: search)
- `MAX_RESULTS`: Max results to return (default: 100)
- `DEBUG_MODE`: Enable verbose logging (default: false)

**Supported Actions**:
- `search` - Search logs for pattern
- `metrics` - Extract metrics (duration, counts, etc.)
- `errors` - Find and categorize errors
- `insights` - Run CloudWatch Insights query

**Usage**:
```bash
# Search for errors in last hour
export LOG_GROUP_NAME="/aws/lambda/my-function"
export ACTION="search" SEARCH_PATTERN="ERROR"
python AWS_CloudWatch_Logs_Analyzer.py

# Extract performance metrics
export ACTION="metrics"
python AWS_CloudWatch_Logs_Analyzer.py

# Find critical errors
export ACTION="errors" LOOKBACK_MINUTES="360"
python AWS_CloudWatch_Logs_Analyzer.py

# Run CloudWatch Insights query
export ACTION="insights" SEARCH_PATTERN="fields @timestamp, @duration"
python AWS_CloudWatch_Logs_Analyzer.py
```

---

### 5. AWS_DynamoDB_Table_Manager.py

**Purpose**: DynamoDB table backup, recovery, and capacity management

**Configuration Variables**:
- `TABLE_NAME`: DynamoDB table name
- `AWS_REGION`: AWS region (default: us-east-1)
- `ENABLE_PITR`: Enable point-in-time recovery (default: true)
- `ACTION`: Operation (default: status)
- `DESIRED_READ_CAPACITY`: RCU for scaling (default: 100)
- `DESIRED_WRITE_CAPACITY`: WCU for scaling (default: 100)

**Supported Actions**:
- `backup` - Create on-demand backup
- `restore` - Restore from backup to new table
- `list` - List available backups
- `scale` - Adjust read/write capacity
- `status` - Get table status
- `enable-pitr` - Enable continuous backups

**Usage**:
```bash
# Create backup
export TABLE_NAME="my-table" ACTION="backup"
python AWS_DynamoDB_Table_Manager.py

# List backups
export ACTION="list"
python AWS_DynamoDB_Table_Manager.py

# Scale table
export ACTION="scale" DESIRED_READ_CAPACITY="200" DESIRED_WRITE_CAPACITY="150"
python AWS_DynamoDB_Table_Manager.py

# Enable PITR
export ACTION="enable-pitr"
python AWS_DynamoDB_Table_Manager.py
```

---

### 6. AWS_IAM_User_Manager.py

**Purpose**: IAM user lifecycle and security management

**Configuration Variables**:
- `USER_NAME`: IAM user name
- `POLICY_NAMES`: Comma-separated policy names to attach
- `INACTIVITY_DAYS`: Days before marking inactive (default: 90)
- `REQUIRE_MFA`: Require MFA setup (default: true)
- `ACTION`: Operation (default: list)
- `MAX_USERS`: Max users to process

**Supported Actions**:
- `create` - Create new user and attach policies
- `delete` - Delete user and cleanup resources
- `list` - List all users
- `audit` - Security audit and findings
- `rotate-keys` - Generate new access keys
- `enable-mfa` - Setup virtual MFA device

**Usage**:
```bash
# Create developer user
export USER_NAME="john-dev"
export POLICY_NAMES="AmazonEC2FullAccess,AmazonS3ReadOnlyAccess"
export ACTION="create"
python AWS_IAM_User_Manager.py

# List all users
export ACTION="list"
python AWS_IAM_User_Manager.py

# Security audit
export ACTION="audit" INACTIVITY_DAYS="90"
python AWS_IAM_User_Manager.py

# Rotate keys for user
export USER_NAME="john-dev" ACTION="rotate-keys"
python AWS_IAM_User_Manager.py

# Setup MFA
export USER_NAME="john-dev" ACTION="enable-mfa"
python AWS_IAM_User_Manager.py
```

---

### 7. AWS_SNS_SQS_Message_Processor.py

**Purpose**: SNS/SQS message publishing, subscription, and queue processing

**Configuration Variables**:
- `RESOURCE_ARN`: SNS topic ARN or resource identifier
- `RESOURCE_URL`: SQS queue URL
- `AWS_REGION`: AWS region (default: us-east-1)
- `BATCH_SIZE`: Messages to process per batch (default: 10)
- `MAX_RETRIES`: Retry attempts (default: 3)
- `ACTION`: Operation (default: process)

**Supported Actions**:
- `process` - Process SQS batch from Lambda or poll queue
- `publish` - Send message to SNS topic
- `subscribe` - Subscribe to SNS topic
- `dlq-check` - Check dead-letter queue
- `purge` - Clear all messages from queue

**Usage**:
```bash
# Publish to SNS
export RESOURCE_ARN="arn:aws:sns:us-east-1:123456789:my-topic"
export ACTION="publish"
export MESSAGE_CONTENT="Alert: Server down"
python AWS_SNS_SQS_Message_Processor.py

# Subscribe to SNS
export ACTION="subscribe"
export SUBSCRIBER_PROTOCOL="email"
export SUBSCRIBER_ENDPOINT="ops@example.com"
python AWS_SNS_SQS_Message_Processor.py

# Check DLQ
export RESOURCE_URL="https://sqs.us-east-1.amazonaws.com/123/my-queue"
export ACTION="dlq-check"
python AWS_SNS_SQS_Message_Processor.py

# Process SQS queue
export ACTION="process" BATCH_SIZE="20"
python AWS_SNS_SQS_Message_Processor.py
```

---

### 8. AWS_Lambda_Function_Manager.py

**Purpose**: Lambda function deployment, versioning, and invocation

**Configuration Variables**:
- `FUNCTION_NAME`: Lambda function name
- `AWS_REGION`: AWS region (default: us-east-1)
- `ROLE_ARN`: IAM role ARN for Lambda execution
- `RUNTIME`: Runtime environment (default: python3.11)
- `HANDLER`: Handler function (default: lambda_function.lambda_handler)
- `MEMORY_SIZE`: Memory in MB (default: 256)
- `TIMEOUT`: Execution timeout in seconds (default: 60)
- `CODE_PATH`: Path to code file or directory
- `ACTION`: Operation (default: list)

**Supported Actions**:
- `create` - Create new Lambda function
- `update` - Update function code only
- `deploy` - Full deployment: update + publish version + alias
- `invoke` - Test invoke with sample payload
- `list` - List versions and aliases
- `delete-version` - Delete specific version
- `alias` - Create or update alias

**Usage**:
```bash
# Create function
export FUNCTION_NAME="my-function"
export ROLE_ARN="arn:aws:iam::123456789:role/lambda-exec"
export CODE_PATH="./src"
export ACTION="create"
python AWS_Lambda_Function_Manager.py

# Update code
export ACTION="update"
python AWS_Lambda_Function_Manager.py

# Deploy new version with alias
export ACTION="deploy" ALIAS_NAME="live"
python AWS_Lambda_Function_Manager.py

# List versions
export ACTION="list"
python AWS_Lambda_Function_Manager.py

# Test invoke
export ACTION="invoke"
python AWS_Lambda_Function_Manager.py

# Update alias to specific version
export ACTION="alias" VERSION_NUMBER="5" ALIAS_NAME="prod"
python AWS_Lambda_Function_Manager.py
```

---

## Lambda Deployment Guide

### Prerequisites

1. Create Lambda execution role:
```bash
aws iam create-role \
  --role-name lambda-execution-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "lambda.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }'

# Attach required policies based on template needs
aws iam attach-role-policy \
  --role-name lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

2. Package template and deploy:
```bash
# As Lambda function
zip lambda_function.zip AWS_S3_Backup_Manager.py
aws lambda create-function \
  --function-name s3-backup-manager \
  --runtime python3.11 \
  --role arn:aws:iam::123456789:role/lambda-execution-role \
  --handler AWS_S3_Backup_Manager.lambda_handler \
  --zip-file fileb://lambda_function.zip \
  --timeout 300 \
  --memory-size 256

# Set environment variables
aws lambda update-function-configuration \
  --function-name s3-backup-manager \
  --environment "Variables={SOURCE_BUCKET=prod-bucket,BACKUP_BUCKET=backup-bucket}"
```

### Scheduled Execution with EventBridge

```bash
# Create EventBridge rule for daily backups at 2 AM UTC
aws events put-rule \
  --name s3-daily-backup \
  --schedule-expression "cron(0 2 * * ? *)" \
  --state ENABLED

# Add Lambda as target
aws events put-targets \
  --rule s3-daily-backup \
  --targets "Id"="1","Arn"="arn:aws:lambda:us-east-1:123456789:function:s3-backup-manager","RoleArn"="arn:aws:iam::123456789:role/eventbridge-lambda-role"
```

## Usage Examples

### Standalone Execution

```bash
# Set environment variables
export AWS_REGION="us-east-1"
export SOURCE_BUCKET="mydata"
export BACKUP_BUCKET="mydata-backup"

# Run directly
python AWS_S3_Backup_Manager.py

# Output
# ================================================================================
# S3 Backup Manager - Started at 2024-01-15T10:30:45.123456
# ================================================================================
# Enabling versioning on mydata-backup...
# Starting sync from mydata to mydata-backup...
# ...
```

### Import as Module

```python
import json
from AWS_S3_Backup_Manager import lambda_handler

# Use as module
result = lambda_handler({}, context=None)
print(json.dumps(result, indent=2, default=str))
```

### Container Deployment

Create Dockerfile:
```dockerfile
FROM public.ecr.aws/lambda/python:3.11

COPY AWS_S3_Backup_Manager.py ${LAMBDA_TASK_ROOT}

CMD ["AWS_S3_Backup_Manager.lambda_handler"]
```

Push to ECR and create Lambda from image:
```bash
docker build -t s3-backup:latest .
docker tag s3-backup:latest 123456789.dkr.ecr.us-east-1.amazonaws.com/s3-backup:latest
docker push 123456789.dkr.ecr.us-east-1.amazonaws.com/s3-backup:latest

aws lambda create-function \
  --function-name s3-backup \
  --role arn:aws:iam::123456789:role/lambda-exec \
  --code ImageUri=123456789.dkr.ecr.us-east-1.amazonaws.com/s3-backup:latest \
  --package-type Image
```

## Error Handling

All templates implement comprehensive error handling:

- **ClientError**: AWS service errors with detailed context
- **ValueError**: Configuration/input validation errors
- **FileNotFoundError**: Missing files or paths
- **TimeoutError**: Operation timeouts
- **KeyError**: Missing required event fields

Errors are logged with full details and returned in structured format:

```json
{
  "statusCode": 500,
  "body": {
    "timestamp": "2024-01-15T10:30:45.123456",
    "action": "backup",
    "errors": [
      "Failed to access S3 bucket: Access Denied"
    ]
  }
}
```

## Logging

All templates use Python logging module with CloudWatch integration:

```python
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Available log levels
logger.info("Operation started")      # Normal operations
logger.warning("Deprecated setting")  # Warnings
logger.error("Failed to process")     # Errors
logger.debug("Variable value: X")     # Debug info
```

View logs in CloudWatch:
```bash
aws logs tail /aws/lambda/s3-backup-manager --follow
```

## Best Practices

1. **Environment Variables**: Always use environment variables for configuration
2. **Logging**: Log all important operations and errors
3. **Error Handling**: Catch specific exceptions, provide meaningful messages
4. **Testing**: Test with `if __name__ == "__main__"` block
5. **Secrets**: Never hardcode credentials in code
6. **Naming**: Follow snake_case for variables/functions, UPPERCASE for constants
7. **Type Hints**: Use type hints for function signatures
8. **Docstrings**: Document all functions with purpose and parameters

## License & Attribution

These templates are provided as-is for DevOps automation tasks.

---

**Version**: 2.0  
**Last Updated**: January 2024  
**Python Version**: 3.11+  
**AWS SDK**: boto3 3.0+
