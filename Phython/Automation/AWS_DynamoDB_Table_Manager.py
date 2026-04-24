"""
AWS DynamoDB Table Manager

Manages DynamoDB tables including backups, point-in-time recovery,
scaling capacity, backup verification, and restoration operations.

Author: DevOps Team
Version: 1.0
"""

import json
import logging
import os
from datetime import datetime, timedelta
from typing import Any, Dict, List, Optional

import boto3
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ============================================================================
# CONFIGURABLE VARIABLES
# ============================================================================

# DynamoDB table name
TABLE_NAME = os.environ.get("TABLE_NAME", "my-table")

# AWS region
REGION = os.environ.get("AWS_REGION", "us-east-1")

# Enable continuous backups (point-in-time recovery)
ENABLE_PITR = os.environ.get("ENABLE_PITR", "true").lower() == "true"

# Action: 'backup', 'restore', 'list', 'scale', 'status', or 'enable-pitr'
ACTION = os.environ.get("ACTION", "status").lower()

# For restoring: backup name or ARN
BACKUP_NAME = os.environ.get("BACKUP_NAME", "")

# For restoring: target table name
RESTORE_TABLE_NAME = os.environ.get("RESTORE_TABLE_NAME", f"{TABLE_NAME}-restored")

# For scaling: desired read/write capacity (provisioned mode only)
DESIRED_READ_CAPACITY = int(os.environ.get("DESIRED_READ_CAPACITY", "100"))
DESIRED_WRITE_CAPACITY = int(os.environ.get("DESIRED_WRITE_CAPACITY", "100"))

# ============================================================================

dynamodb_client = boto3.client("dynamodb", region_name=REGION)


def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
    """
    Lambda handler for DynamoDB management.
    
    Args:
        event: Lambda event with optional action override
        context: Lambda context object
    
    Returns:
        Dict with operation results
    """
    
    logger.info("=" * 80)
    logger.info(f"DynamoDB Table Manager - Started at {datetime.now().isoformat()}")
    logger.info(f"Table: {TABLE_NAME}, Action: {ACTION}")
    logger.info("=" * 80)
    
    action = event.get("action", ACTION) if event else ACTION
    
    results = {
        "timestamp": datetime.now().isoformat(),
        "action": action,
        "table": TABLE_NAME,
        "data": {},
        "errors": []
    }
    
    try:
        if action == "backup":
            data = create_backup()
            results["data"]["backup"] = data
        
        elif action == "restore":
            if not BACKUP_NAME:
                raise ValueError("BACKUP_NAME required for restore action")
            data = restore_from_backup()
            results["data"]["restore"] = data
        
        elif action == "list":
            data = list_backups()
            results["data"]["backups"] = data
        
        elif action == "scale":
            data = scale_capacity()
            results["data"]["scaling"] = data
        
        elif action == "status":
            data = get_table_status()
            results["data"]["status"] = data
        
        elif action == "enable-pitr":
            data = enable_pitr()
            results["data"]["pitr"] = data
        
        else:
            raise ValueError(f"Unknown action: {action}")
        
        logger.info(f"Success: {json.dumps(results, indent=2, default=str)}")
        return {"statusCode": 200, "body": results}
        
    except Exception as e:
        error_msg = f"DynamoDB operation failed: {str(e)}"
        logger.error(error_msg)
        results["errors"].append(error_msg)
        return {"statusCode": 500, "body": results}


def create_backup() -> Dict[str, Any]:
    """
    Create on-demand backup of DynamoDB table.
    
    Returns:
        Backup details
    """
    
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup_name = f"{TABLE_NAME}-backup-{timestamp}"
    
    try:
        logger.info(f"Creating backup: {backup_name}")
        response = dynamodb_client.create_backup(
            TableName=TABLE_NAME,
            BackupName=backup_name
        )
        
        backup = response["BackupDetails"]
        logger.info(f"Backup initiated: {backup['BackupArn']}")
        
        return {
            "backup_name": backup["BackupName"],
            "backup_arn": backup["BackupArn"],
            "status": backup["BackupStatus"],
            "create_time": backup["BackupCreationDateTime"].isoformat(),
            "size_bytes": backup.get("BackupSizeBytes", 0)
        }
    
    except ClientError as e:
        logger.error(f"Backup creation failed: {str(e)}")
        raise


def list_backups(max_results: int = 20) -> List[Dict[str, Any]]:
    """
    List available backups for table.
    
    Args:
        max_results: Maximum backups to return
    
    Returns:
        List of backup details
    """
    
    try:
        logger.info("Listing backups")
        response = dynamodb_client.list_backups(
            TableName=TABLE_NAME,
            Limit=max_results
        )
        
        backups = []
        for backup in response.get("BackupSummaries", []):
            backups.append({
                "backup_name": backup["BackupName"],
                "backup_arn": backup["BackupArn"],
                "status": backup["BackupStatus"],
                "create_time": backup["BackupCreationDateTime"].isoformat(),
                "size_bytes": backup.get("BackupSizeBytes", 0),
                "type": backup["BackupType"]
            })
        
        logger.info(f"Found {len(backups)} backups")
        return backups
    
    except ClientError as e:
        logger.error(f"List backups failed: {str(e)}")
        raise


def restore_from_backup() -> Dict[str, Any]:
    """
    Restore table from backup.
    
    Returns:
        Restoration details
    """
    
    try:
        logger.info(f"Restoring from backup: {BACKUP_NAME} to {RESTORE_TABLE_NAME}")
        response = dynamodb_client.restore_table_from_backup(
            TargetTableName=RESTORE_TABLE_NAME,
            BackupArn=BACKUP_NAME  # Can be backup ARN or will be looked up by name
        )
        
        table = response["TableDescription"]
        logger.info(f"Restore in progress: {table['TableArn']}")
        
        return {
            "restored_table": table["TableName"],
            "table_arn": table["TableArn"],
            "status": table["TableStatus"],
            "create_time": table["CreationDateTime"].isoformat(),
            "item_count": table.get("ItemCount", 0)
        }
    
    except ClientError as e:
        logger.error(f"Restore failed: {str(e)}")
        raise


def scale_capacity() -> Dict[str, Any]:
    """
    Scale read/write capacity of DynamoDB table (provisioned mode).
    
    Returns:
        Scaling details
    """
    
    try:
        logger.info(f"Scaling capacity to RCU={DESIRED_READ_CAPACITY}, WCU={DESIRED_WRITE_CAPACITY}")
        response = dynamodb_client.update_table(
            TableName=TABLE_NAME,
            BillingMode="PROVISIONED",
            ProvisionedThroughput={
                "ReadCapacityUnits": DESIRED_READ_CAPACITY,
                "WriteCapacityUnits": DESIRED_WRITE_CAPACITY
            }
        )
        
        table = response["TableDescription"]
        provisioned = table.get("ProvisionedThroughput", {})
        
        logger.info(f"Scaling in progress for {TABLE_NAME}")
        
        return {
            "table": table["TableName"],
            "status": table["TableStatus"],
            "read_capacity": provisioned.get("ReadCapacityUnits", 0),
            "write_capacity": provisioned.get("WriteCapacityUnits", 0),
            "last_update_time": table["TableArn"]
        }
    
    except ClientError as e:
        logger.error(f"Scaling failed: {str(e)}")
        raise


def enable_pitr() -> Dict[str, Any]:
    """
    Enable continuous backups (Point-in-Time Recovery).
    
    Returns:
        PITR details
    """
    
    try:
        logger.info(f"Enabling PITR for {TABLE_NAME}")
        response = dynamodb_client.update_continuous_backups(
            TableName=TABLE_NAME,
            PointInTimeRecoverySpecification={
                "PointInTimeRecoveryEnabled": True
            }
        )
        
        pitr = response["ContinuousBackupsDescription"]
        logger.info(f"PITR enabled: {pitr['PointInTimeRecoveryDescription']['PointInTimeRecoveryStatus']}")
        
        return {
            "table": TABLE_NAME,
            "pitr_status": pitr["PointInTimeRecoveryDescription"]["PointInTimeRecoveryStatus"],
            "earliest_restore_time": pitr.get("EarliestRestorableDateTime", "").isoformat(),
            "latest_restore_time": pitr.get("LatestRestorableDateTime", "").isoformat()
        }
    
    except ClientError as e:
        logger.error(f"Enable PITR failed: {str(e)}")
        raise


def get_table_status() -> Dict[str, Any]:
    """
    Get detailed table status and information.
    
    Returns:
        Table status details
    """
    
    try:
        logger.info(f"Getting status for {TABLE_NAME}")
        response = dynamodb_client.describe_table(TableName=TABLE_NAME)
        
        table = response["Table"]
        
        status_info = {
            "table_name": table["TableName"],
            "table_arn": table["TableArn"],
            "status": table["TableStatus"],
            "item_count": table.get("ItemCount", 0),
            "size_bytes": table.get("TableSizeBytes", 0),
            "create_time": table["CreationDateTime"].isoformat(),
            "billing_mode": table.get("BillingModeSummary", {}).get("BillingMode", "UNKNOWN")
        }
        
        # Add capacity info if provisioned
        if "ProvisionedThroughput" in table:
            provisioned = table["ProvisionedThroughput"]
            status_info["provisioned"] = {
                "read_capacity": provisioned.get("ReadCapacityUnits", 0),
                "write_capacity": provisioned.get("WriteCapacityUnits", 0)
            }
        
        # Add PITR info
        try:
            pitr_response = dynamodb_client.describe_continuous_backups(TableName=TABLE_NAME)
            pitr = pitr_response["ContinuousBackupsDescription"]
            status_info["pitr_enabled"] = (
                pitr["PointInTimeRecoveryDescription"]["PointInTimeRecoveryStatus"] == "ENABLED"
            )
        except:
            status_info["pitr_enabled"] = False
        
        logger.info(f"Status retrieved for {TABLE_NAME}")
        return status_info
    
    except ClientError as e:
        logger.error(f"Get status failed: {str(e)}")
        raise


if __name__ == "__main__":
    logger.info("Running DynamoDB Table Manager in standalone mode")
    result = lambda_handler({})
    print(json.dumps(result, indent=2, default=str))
