"""
AWS S3 Backup Manager

Automates S3 bucket operations including syncing, backup, lifecycle management,
versioning, and cleanup of old objects. Can be run as a cron job or Lambda.

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

# Source and destination bucket names
SOURCE_BUCKET = os.environ.get("SOURCE_BUCKET", "source-bucket-name")
BACKUP_BUCKET = os.environ.get("BACKUP_BUCKET", "backup-bucket-name")

# S3 prefix/folder to process (empty string = entire bucket)
PREFIX = os.environ.get("PREFIX", "")

# Enable versioning on backup bucket
ENABLE_VERSIONING = os.environ.get("ENABLE_VERSIONING", "true").lower() == "true"

# Delete objects older than N days
DELETE_OLDER_THAN_DAYS = int(os.environ.get("DELETE_OLDER_THAN_DAYS", "90"))

# Maximum objects to process per run (0 = no limit)
MAX_OBJECTS = int(os.environ.get("MAX_OBJECTS", "0"))

# ============================================================================

s3_client = boto3.client("s3")


def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
    """
    Lambda handler for S3 backup operations.
    
    Args:
        event: Lambda event (can trigger backup, cleanup, or versioning operations)
        context: Lambda context object
    
    Returns:
        Dict with operation results and statistics
    """
    
    logger.info("=" * 80)
    logger.info(f"S3 Backup Manager - Started at {datetime.now().isoformat()}")
    logger.info("=" * 80)
    
    results = {
        "timestamp": datetime.now().isoformat(),
        "operations": [],
        "files_processed": 0,
        "bytes_processed": 0,
        "errors": []
    }
    
    try:
        # Enable versioning if configured
        if ENABLE_VERSIONING:
            logger.info(f"Enabling versioning on {BACKUP_BUCKET}...")
            enable_bucket_versioning(BACKUP_BUCKET)
            results["operations"].append("versioning_enabled")
        
        # Sync objects from source to backup bucket
        logger.info(f"Starting sync from {SOURCE_BUCKET} to {BACKUP_BUCKET}...")
        sync_result = sync_buckets(SOURCE_BUCKET, BACKUP_BUCKET)
        results["files_processed"] += sync_result["files_copied"]
        results["bytes_processed"] += sync_result["bytes_copied"]
        results["operations"].append("sync_completed")
        
        # Clean up old objects in backup bucket
        logger.info(f"Cleaning up objects older than {DELETE_OLDER_THAN_DAYS} days...")
        cleanup_result = cleanup_old_objects(BACKUP_BUCKET)
        results["files_processed"] += cleanup_result["files_deleted"]
        results["operations"].append("cleanup_completed")
        
        logger.info(f"Success: {json.dumps(results, indent=2)}")
        return {"statusCode": 200, "body": results}
        
    except Exception as e:
        error_msg = f"Backup operation failed: {str(e)}"
        logger.error(error_msg)
        results["errors"].append(error_msg)
        return {"statusCode": 500, "body": results}


def enable_bucket_versioning(bucket: str) -> None:
    """Enable versioning on S3 bucket."""
    try:
        s3_client.put_bucket_versioning(
            Bucket=bucket,
            VersioningConfiguration={"Status": "Enabled"}
        )
        logger.info(f"Versioning enabled on {bucket}")
    except ClientError as e:
        logger.error(f"Failed to enable versioning: {str(e)}")
        raise


def sync_buckets(source_bucket: str, dest_bucket: str) -> Dict[str, Any]:
    """
    Sync objects from source to destination bucket.
    
    Args:
        source_bucket: Source bucket name
        dest_bucket: Destination bucket name
    
    Returns:
        Dict with copy statistics
    """
    
    result = {"files_copied": 0, "bytes_copied": 0, "skipped": 0}
    count = 0
    
    try:
        paginator = s3_client.get_paginator("list_objects_v2")
        pages = paginator.paginate(Bucket=source_bucket, Prefix=PREFIX)
        
        for page in pages:
            if "Contents" not in page:
                continue
            
            for obj in page["Contents"]:
                # Check max objects limit
                if MAX_OBJECTS > 0 and count >= MAX_OBJECTS:
                    logger.info(f"Reached max objects limit: {MAX_OBJECTS}")
                    break
                
                key = obj["Key"]
                size = obj["Size"]
                
                # Skip if object already exists in destination
                if object_exists(dest_bucket, key):
                    logger.debug(f"Skipping existing object: {key}")
                    result["skipped"] += 1
                    continue
                
                # Copy object
                try:
                    copy_source = {"Bucket": source_bucket, "Key": key}
                    s3_client.copy_object(
                        Bucket=dest_bucket,
                        Key=key,
                        CopySource=copy_source
                    )
                    result["files_copied"] += 1
                    result["bytes_copied"] += size
                    logger.info(f"Copied: {key} ({size} bytes)")
                    count += 1
                except ClientError as e:
                    logger.error(f"Failed to copy {key}: {str(e)}")
        
        logger.info(f"Sync complete: {result['files_copied']} files, {result['bytes_copied']} bytes")
        return result
        
    except ClientError as e:
        logger.error(f"Sync failed: {str(e)}")
        raise


def object_exists(bucket: str, key: str) -> bool:
    """Check if object exists in bucket."""
    try:
        s3_client.head_object(Bucket=bucket, Key=key)
        return True
    except ClientError as e:
        if e.response["Error"]["Code"] == "404":
            return False
        raise


def cleanup_old_objects(bucket: str) -> Dict[str, Any]:
    """
    Delete objects older than DELETE_OLDER_THAN_DAYS.
    
    Args:
        bucket: Bucket to clean
    
    Returns:
        Dict with deletion statistics
    """
    
    result = {"files_deleted": 0, "bytes_freed": 0}
    cutoff_date = datetime.now() - timedelta(days=DELETE_OLDER_THAN_DAYS)
    
    try:
        paginator = s3_client.get_paginator("list_objects_v2")
        pages = paginator.paginate(Bucket=bucket, Prefix=PREFIX)
        
        for page in pages:
            if "Contents" not in page:
                continue
            
            for obj in page["Contents"]:
                last_modified = obj["LastModified"].replace(tzinfo=None)
                
                if last_modified < cutoff_date:
                    key = obj["Key"]
                    size = obj["Size"]
                    
                    try:
                        s3_client.delete_object(Bucket=bucket, Key=key)
                        result["files_deleted"] += 1
                        result["bytes_freed"] += size
                        logger.info(f"Deleted: {key} (modified: {last_modified})")
                    except ClientError as e:
                        logger.error(f"Failed to delete {key}: {str(e)}")
        
        logger.info(f"Cleanup complete: {result['files_deleted']} files deleted")
        return result
        
    except ClientError as e:
        logger.error(f"Cleanup failed: {str(e)}")
        raise


if __name__ == "__main__":
    logger.info("Running S3 Backup Manager in standalone mode")
    result = lambda_handler({})
    print(json.dumps(result, indent=2))
