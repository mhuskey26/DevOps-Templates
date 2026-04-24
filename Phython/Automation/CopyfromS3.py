"""
S3 Object Copy Lambda Function

Copies objects from a source S3 bucket to a target S3 bucket when objects 
are uploaded to the source bucket. This is typically triggered by S3 events.

Author: Updated for modern Python standards
Version: 2.0
"""

import json
import logging
import os
from typing import Any, Dict, Optional
from urllib.parse import unquote_plus

import boto3
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ============================================================================
# CONFIGURABLE VARIABLES - UPDATE THESE FOR YOUR ENVIRONMENT
# ============================================================================

# Target S3 bucket name (where objects will be copied)
TARGET_BUCKET = os.environ.get("TARGET_BUCKET", "target-bucket-name")

# Maximum wait time for object to persist (seconds)
WAIT_TIMEOUT = int(os.environ.get("WAIT_TIMEOUT", "300"))

# Enable verbose logging
DEBUG_MODE = os.environ.get("DEBUG_MODE", "false").lower() == "true"

# ============================================================================

# Initialize S3 client
s3_client = boto3.client("s3")


def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    AWS Lambda handler to copy S3 objects from source to target bucket.
    
    Args:
        event: S3 event containing bucket and object information
        context: Lambda context object with execution metadata
    
    Returns:
        Dict with status code, message, and copied object metadata
    """
    
    logger.info("=" * 80)
    logger.info("S3 Object Copy Lambda - Started")
    logger.info("=" * 80)
    
    # Log Lambda context information
    if context:
        logger.info(f"Log Stream Name: {context.log_stream_name}")
        logger.info(f"Log Group Name: {context.log_group_name}")
        logger.info(f"Request ID: {context.aws_request_id}")
        logger.info(f"Memory Limit (MB): {context.memory_limit_in_mb}")
    
    try:
        # Extract source bucket and object key from S3 event
        source_bucket = extract_source_bucket(event)
        object_key = extract_object_key(event)
        
        logger.info(f"Source Bucket: {source_bucket}")
        logger.info(f"Object Key: {object_key}")
        logger.info(f"Target Bucket: {TARGET_BUCKET}")
        
        # Validate configuration
        if not TARGET_BUCKET or TARGET_BUCKET == "target-bucket-name":
            raise ValueError("TARGET_BUCKET environment variable not set or using default value")
        
        # Wait for object to persist in S3
        logger.info(f"Waiting for object to persist (timeout: {WAIT_TIMEOUT}s)...")
        wait_for_object(source_bucket, object_key)
        
        # Copy object from source to target bucket
        logger.info("Copying object to target bucket...")
        response = copy_object(source_bucket, object_key)
        
        # Prepare success response
        result = {
            "statusCode": 200,
            "message": "Object copied successfully",
            "source_bucket": source_bucket,
            "target_bucket": TARGET_BUCKET,
            "object_key": object_key,
            "content_type": response.get("ContentType", "unknown"),
            "copy_source": response.get("CopyObjectResult", {})
        }
        
        logger.info(f"Success: {json.dumps(result, indent=2)}")
        return result
        
    except KeyError as e:
        error_msg = f"Missing required field in S3 event: {str(e)}"
        logger.error(error_msg)
        return error_response(400, error_msg)
    
    except ClientError as e:
        error_msg = f"AWS S3 Client Error: {str(e)}"
        logger.error(error_msg)
        return error_response(500, error_msg)
    
    except Exception as e:
        error_msg = f"Unexpected Error: {str(e)}"
        logger.error(error_msg)
        if DEBUG_MODE:
            logger.exception("Full traceback:")
        return error_response(500, error_msg)


def extract_source_bucket(event: Dict[str, Any]) -> str:
    """Extract source bucket name from S3 event."""
    return event["Records"][0]["s3"]["bucket"]["name"]


def extract_object_key(event: Dict[str, Any]) -> str:
    """Extract and URL-decode object key from S3 event."""
    raw_key = event["Records"][0]["s3"]["object"]["key"]
    return unquote_plus(raw_key)


def wait_for_object(bucket: str, key: str) -> None:
    """
    Wait for object to persist in S3 service.
    
    Args:
        bucket: Source bucket name
        key: Object key
    
    Raises:
        ClientError: If waiter fails or times out
    """
    try:
        waiter = s3_client.get_waiter("object_exists")
        waiter.wait(
            Bucket=bucket,
            Key=key,
            WaiterConfig={"Delay": 1, "MaxAttempts": WAIT_TIMEOUT}
        )
        logger.info(f"Object persisted: s3://{bucket}/{key}")
    except ClientError as e:
        logger.error(f"Waiter failed: {str(e)}")
        raise


def copy_object(source_bucket: str, object_key: str) -> Dict[str, Any]:
    """
    Copy object from source bucket to target bucket.
    
    Args:
        source_bucket: Source S3 bucket name
        object_key: Object key to copy
    
    Returns:
        S3 copy_object response
    
    Raises:
        ClientError: If copy operation fails
    """
    copy_source = {"Bucket": source_bucket, "Key": object_key}
    
    try:
        response = s3_client.copy_object(
            Bucket=TARGET_BUCKET,
            Key=object_key,
            CopySource=copy_source
        )
        logger.info(f"Copy successful: {json.dumps(response['CopyObjectResult'])}")
        return response
    except ClientError as e:
        logger.error(f"Copy failed: {str(e)}")
        raise


def error_response(status_code: int, message: str) -> Dict[str, Any]:
    """
    Generate standardized error response.
    
    Args:
        status_code: HTTP status code
        message: Error message
    
    Returns:
        Formatted error response
    """
    return {
        "statusCode": status_code,
        "message": message,
        "error": True
    }


if __name__ == "__main__":
    # Local testing (uncomment and update event for local testing)
    logger.info("Running in local mode - not Lambda")
    
    test_event = {
        "Records": [
            {
                "s3": {
                    "bucket": {"name": "source-bucket"},
                    "object": {"key": "path/to/test-file.txt"}
                }
            }
        ]
    }
    
    # Create mock context for local testing
    class MockContext:
        log_stream_name = "local-test"
        log_group_name = "local-test-group"
        aws_request_id = "local-test-id"
        memory_limit_in_mb = 128
    
    result = lambda_handler(test_event, MockContext())
    logger.info(f"Result: {json.dumps(result, indent=2)}")