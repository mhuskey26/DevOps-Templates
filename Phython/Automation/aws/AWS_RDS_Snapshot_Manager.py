"""
AWS RDS Snapshot Manager

Automates RDS database snapshots including creation, retention policies,
copying snapshots to other regions, and cleanup of old snapshots.

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

# RDS database identifier
DB_INSTANCE_ID = os.environ.get("DB_INSTANCE_ID", "my-database")

# AWS regions
PRIMARY_REGION = os.environ.get("PRIMARY_REGION", "us-east-1")
BACKUP_REGION = os.environ.get("BACKUP_REGION", "us-west-2")

# Snapshot retention (days)
RETENTION_DAYS = int(os.environ.get("RETENTION_DAYS", "30"))

# Copy snapshots to backup region
CROSS_REGION_COPY = os.environ.get("CROSS_REGION_COPY", "true").lower() == "true"

# Action: 'create', 'list', 'cleanup', or 'copy'
ACTION = os.environ.get("ACTION", "create").lower()

# ============================================================================

rds_client = boto3.client("rds", region_name=PRIMARY_REGION)
rds_backup_client = boto3.client("rds", region_name=BACKUP_REGION)


def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
    """
    Lambda handler for RDS snapshot management.
    
    Args:
        event: Lambda event with optional action override
        context: Lambda context object
    
    Returns:
        Dict with snapshot operation results
    """
    
    logger.info("=" * 80)
    logger.info(f"RDS Snapshot Manager - Started at {datetime.now().isoformat()}")
    logger.info(f"Database: {DB_INSTANCE_ID}, Action: {ACTION}")
    logger.info("=" * 80)
    
    action = event.get("action", ACTION) if event else ACTION
    
    results = {
        "timestamp": datetime.now().isoformat(),
        "action": action,
        "database": DB_INSTANCE_ID,
        "snapshots": [],
        "operations_count": 0,
        "errors": []
    }
    
    try:
        if action == "create":
            result = create_snapshot()
            results["operations_count"] += 1
            results["snapshots"].append(result)
        
        elif action == "list":
            snapshots = list_snapshots()
            results["snapshots"] = snapshots
        
        elif action == "cleanup":
            deleted = cleanup_old_snapshots()
            results["operations_count"] = deleted
        
        elif action == "copy":
            if CROSS_REGION_COPY:
                result = copy_latest_snapshot()
                results["operations_count"] += 1
                results["snapshots"].append(result)
        
        else:
            raise ValueError(f"Unknown action: {action}")
        
        logger.info(f"Success: {json.dumps(results, indent=2)}")
        return {"statusCode": 200, "body": results}
        
    except Exception as e:
        error_msg = f"Snapshot operation failed: {str(e)}"
        logger.error(error_msg)
        results["errors"].append(error_msg)
        return {"statusCode": 500, "body": results}


def create_snapshot() -> Dict[str, Any]:
    """
    Create new RDS snapshot.
    
    Returns:
        Snapshot details
    """
    
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    snapshot_id = f"{DB_INSTANCE_ID}-snapshot-{timestamp}"
    
    try:
        logger.info(f"Creating snapshot: {snapshot_id}")
        response = rds_client.create_db_snapshot(
            DBSnapshotIdentifier=snapshot_id,
            DBInstanceIdentifier=DB_INSTANCE_ID,
            Tags=[
                {"Key": "ManagedBy", "Value": "Lambda"},
                {"Key": "CreatedAt", "Value": datetime.now().isoformat()}
            ]
        )
        
        snapshot = response["DBSnapshot"]
        logger.info(f"Snapshot created: {snapshot_id}")
        
        return {
            "snapshot_id": snapshot["DBSnapshotIdentifier"],
            "status": snapshot["Status"],
            "create_time": snapshot["SnapshotCreateTime"].isoformat(),
            "size_gb": snapshot.get("AllocatedStorage", 0)
        }
    
    except ClientError as e:
        logger.error(f"Failed to create snapshot: {str(e)}")
        raise


def list_snapshots(max_results: int = 20) -> List[Dict[str, Any]]:
    """
    List RDS snapshots for database.
    
    Args:
        max_results: Maximum snapshots to return
    
    Returns:
        List of snapshot details
    """
    
    try:
        response = rds_client.describe_db_snapshots(
            DBInstanceIdentifier=DB_INSTANCE_ID,
            MaxRecords=min(max_results, 100)
        )
        
        snapshots = []
        for snapshot in response["DBSnapshots"]:
            snapshots.append({
                "snapshot_id": snapshot["DBSnapshotIdentifier"],
                "status": snapshot["Status"],
                "create_time": snapshot["SnapshotCreateTime"].isoformat(),
                "size_gb": snapshot.get("AllocatedStorage", 0),
                "type": snapshot["SnapshotType"]
            })
        
        logger.info(f"Found {len(snapshots)} snapshots")
        return snapshots
    
    except ClientError as e:
        logger.error(f"Failed to list snapshots: {str(e)}")
        raise


def cleanup_old_snapshots() -> int:
    """
    Delete snapshots older than RETENTION_DAYS.
    
    Returns:
        Number of snapshots deleted
    """
    
    deleted_count = 0
    cutoff_date = datetime.now(datetime.now().astimezone().tzinfo) - timedelta(days=RETENTION_DAYS)
    
    try:
        response = rds_client.describe_db_snapshots(
            DBInstanceIdentifier=DB_INSTANCE_ID
        )
        
        for snapshot in response["DBSnapshots"]:
            if snapshot["SnapshotType"] != "manual":
                continue
            
            create_time = snapshot["SnapshotCreateTime"]
            
            if create_time < cutoff_date:
                snapshot_id = snapshot["DBSnapshotIdentifier"]
                try:
                    rds_client.delete_db_snapshot(
                        DBSnapshotIdentifier=snapshot_id,
                        SkipFinalSnapshot=True
                    )
                    logger.info(f"Deleted snapshot: {snapshot_id} (created: {create_time})")
                    deleted_count += 1
                except ClientError as e:
                    logger.error(f"Failed to delete {snapshot_id}: {str(e)}")
        
        logger.info(f"Cleanup complete: {deleted_count} snapshots deleted")
        return deleted_count
    
    except ClientError as e:
        logger.error(f"Cleanup failed: {str(e)}")
        raise


def copy_latest_snapshot() -> Dict[str, Any]:
    """
    Copy latest manual snapshot to backup region.
    
    Returns:
        Copy operation details
    """
    
    try:
        # Get latest snapshot
        response = rds_client.describe_db_snapshots(
            DBInstanceIdentifier=DB_INSTANCE_ID,
            SnapshotType="manual",
            MaxRecords=1
        )
        
        if not response["DBSnapshots"]:
            raise ValueError("No manual snapshots found")
        
        latest_snapshot = response["DBSnapshots"][0]
        source_snapshot_id = latest_snapshot["DBSnapshotIdentifier"]
        
        timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        target_snapshot_id = f"{source_snapshot_id}-{BACKUP_REGION}-{timestamp}"
        
        logger.info(f"Copying snapshot {source_snapshot_id} to {BACKUP_REGION}")
        
        copy_response = rds_client.copy_db_snapshot(
            SourceDBSnapshotIdentifier=source_snapshot_id,
            TargetDBSnapshotIdentifier=target_snapshot_id,
            SourceRegion=PRIMARY_REGION,
            Tags=[
                {"Key": "CopyRegion", "Value": BACKUP_REGION},
                {"Key": "CopiedFrom", "Value": source_snapshot_id}
            ]
        )
        
        copy_snapshot = copy_response["DBSnapshot"]
        logger.info(f"Copy initiated: {target_snapshot_id}")
        
        return {
            "source_snapshot": source_snapshot_id,
            "target_snapshot": copy_snapshot["DBSnapshotIdentifier"],
            "target_region": BACKUP_REGION,
            "status": copy_snapshot["Status"]
        }
    
    except ClientError as e:
        logger.error(f"Copy failed: {str(e)}")
        raise


if __name__ == "__main__":
    logger.info("Running RDS Snapshot Manager in standalone mode")
    result = lambda_handler({})
    print(json.dumps(result, indent=2))
