"""
AWS SNS/SQS Message Processor

Processes messages from SNS topics and SQS queues with error handling,
retry logic, dead-letter queue management, and monitoring.

Author: DevOps Team
Version: 1.0
"""

import json
import logging
import os
from datetime import datetime
from typing import Any, Dict, List, Optional

import boto3
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ============================================================================
# CONFIGURABLE VARIABLES
# ============================================================================

# SNS topic ARN or SQS queue URL
RESOURCE_ARN = os.environ.get("RESOURCE_ARN", "")
RESOURCE_URL = os.environ.get("RESOURCE_URL", "")

# AWS region
REGION = os.environ.get("AWS_REGION", "us-east-1")

# Message batch size for processing
BATCH_SIZE = int(os.environ.get("BATCH_SIZE", "10"))

# Maximum retry attempts
MAX_RETRIES = int(os.environ.get("MAX_RETRIES", "3"))

# Action: 'process', 'publish', 'subscribe', 'dlq-check', or 'purge'
ACTION = os.environ.get("ACTION", "process").lower()

# Message to publish (for 'publish' action)
MESSAGE_CONTENT = os.environ.get("MESSAGE_CONTENT", "")

# Subscriber endpoint (for 'subscribe' action)
SUBSCRIBER_ENDPOINT = os.environ.get("SUBSCRIBER_ENDPOINT", "")
SUBSCRIBER_PROTOCOL = os.environ.get("SUBSCRIBER_PROTOCOL", "email")

# ============================================================================

sns_client = boto3.client("sns", region_name=REGION)
sqs_client = boto3.client("sqs", region_name=REGION)


def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
    """
    Lambda handler for SNS/SQS message processing.
    
    Args:
        event: Lambda event (can be SQS message batch or custom action trigger)
        context: Lambda context object
    
    Returns:
        Dict with operation results
    """
    
    logger.info("=" * 80)
    logger.info(f"SNS/SQS Message Processor - Started at {datetime.now().isoformat()}")
    logger.info("=" * 80)
    
    action = event.get("action", ACTION) if event else ACTION
    
    results = {
        "timestamp": datetime.now().isoformat(),
        "action": action,
        "data": {},
        "errors": []
    }
    
    try:
        # Check if this is an SQS event from Lambda
        if "Records" in event and not action:
            action = "process"
            results["action"] = action
        
        if action == "process":
            if "Records" in event:
                # Process SQS batch from Lambda
                data = process_sqs_batch(event["Records"])
            else:
                # Poll SQS queue
                data = poll_sqs_queue()
            results["data"]["processed"] = data
        
        elif action == "publish":
            if not MESSAGE_CONTENT:
                raise ValueError("MESSAGE_CONTENT required for publish action")
            data = publish_message()
            results["data"]["published"] = data
        
        elif action == "subscribe":
            if not SUBSCRIBER_ENDPOINT:
                raise ValueError("SUBSCRIBER_ENDPOINT required for subscribe action")
            data = subscribe_to_topic()
            results["data"]["subscription"] = data
        
        elif action == "dlq-check":
            data = check_dlq()
            results["data"]["dlq"] = data
        
        elif action == "purge":
            data = purge_queue()
            results["data"]["purged"] = data
        
        else:
            raise ValueError(f"Unknown action: {action}")
        
        logger.info(f"Success: {json.dumps(results, indent=2, default=str)}")
        return {"statusCode": 200, "body": results}
        
    except Exception as e:
        error_msg = f"Message processing failed: {str(e)}"
        logger.error(error_msg)
        results["errors"].append(error_msg)
        return {"statusCode": 500, "body": results}


def process_sqs_batch(records: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Process SQS message batch from Lambda trigger.
    
    Args:
        records: SQS Records from Lambda event
    
    Returns:
        Processing statistics
    """
    
    stats = {
        "total_messages": len(records),
        "processed": 0,
        "failed": 0,
        "errors": []
    }
    
    logger.info(f"Processing {len(records)} SQS messages")
    
    for record in records:
        try:
            message_body = json.loads(record["body"])
            message_id = record["messageId"]
            
            logger.info(f"Processing message {message_id}")
            
            # Process message
            result = handle_message(message_body)
            
            if result.get("success"):
                stats["processed"] += 1
                logger.info(f"Successfully processed: {message_id}")
            else:
                stats["failed"] += 1
                error = result.get("error", "Unknown error")
                stats["errors"].append({"message_id": message_id, "error": error})
                logger.error(f"Failed to process {message_id}: {error}")
        
        except Exception as e:
            stats["failed"] += 1
            error_msg = f"Error processing record: {str(e)}"
            stats["errors"].append(error_msg)
            logger.error(error_msg)
    
    return stats


def poll_sqs_queue() -> Dict[str, Any]:
    """
    Poll SQS queue for messages.
    
    Returns:
        Processing statistics
    """
    
    stats = {
        "messages_received": 0,
        "messages_processed": 0,
        "messages_failed": 0
    }
    
    if not RESOURCE_URL:
        raise ValueError("RESOURCE_URL required for SQS polling")
    
    try:
        logger.info(f"Polling queue: {RESOURCE_URL}")
        response = sqs_client.receive_message(
            QueueUrl=RESOURCE_URL,
            MaxNumberOfMessages=BATCH_SIZE,
            WaitTimeSeconds=20
        )
        
        messages = response.get("Messages", [])
        stats["messages_received"] = len(messages)
        
        for message in messages:
            try:
                message_id = message["MessageId"]
                receipt_handle = message["ReceiptHandle"]
                
                # Parse and process message
                body = json.loads(message["Body"])
                result = handle_message(body)
                
                if result.get("success"):
                    # Delete message from queue
                    sqs_client.delete_message(
                        QueueUrl=RESOURCE_URL,
                        ReceiptHandle=receipt_handle
                    )
                    stats["messages_processed"] += 1
                    logger.info(f"Processed and deleted: {message_id}")
                else:
                    stats["messages_failed"] += 1
                    logger.error(f"Failed to process: {message_id}")
            
            except Exception as e:
                stats["messages_failed"] += 1
                logger.error(f"Error processing message: {str(e)}")
        
        logger.info(f"Poll complete: {stats}")
        return stats
    
    except ClientError as e:
        logger.error(f"Poll failed: {str(e)}")
        raise


def publish_message() -> Dict[str, Any]:
    """
    Publish message to SNS topic.
    
    Returns:
        Publish operation details
    """
    
    if not RESOURCE_ARN:
        raise ValueError("RESOURCE_ARN required for SNS publishing")
    
    try:
        logger.info(f"Publishing message to {RESOURCE_ARN}")
        
        response = sns_client.publish(
            TopicArn=RESOURCE_ARN,
            Subject=f"Message from Lambda - {datetime.now().isoformat()}",
            Message=MESSAGE_CONTENT
        )
        
        logger.info(f"Message published: {response['MessageId']}")
        
        return {
            "topic_arn": RESOURCE_ARN,
            "message_id": response["MessageId"],
            "timestamp": datetime.now().isoformat()
        }
    
    except ClientError as e:
        logger.error(f"Publish failed: {str(e)}")
        raise


def subscribe_to_topic() -> Dict[str, Any]:
    """
    Subscribe to SNS topic.
    
    Returns:
        Subscription details
    """
    
    if not RESOURCE_ARN:
        raise ValueError("RESOURCE_ARN required for subscription")
    
    try:
        logger.info(f"Subscribing {SUBSCRIBER_ENDPOINT} to {RESOURCE_ARN}")
        
        response = sns_client.subscribe(
            TopicArn=RESOURCE_ARN,
            Protocol=SUBSCRIBER_PROTOCOL,
            Endpoint=SUBSCRIBER_ENDPOINT,
            Attributes={"RawMessageDelivery": "true"}
        )
        
        subscription_arn = response["SubscriptionArn"]
        logger.info(f"Subscription created: {subscription_arn}")
        
        return {
            "subscription_arn": subscription_arn,
            "protocol": SUBSCRIBER_PROTOCOL,
            "endpoint": SUBSCRIBER_ENDPOINT,
            "status": "pending" if subscription_arn == "PendingConfirmation" else "active"
        }
    
    except ClientError as e:
        logger.error(f"Subscribe failed: {str(e)}")
        raise


def check_dlq() -> Dict[str, Any]:
    """
    Check dead-letter queue for messages.
    
    Returns:
        DLQ statistics
    """
    
    if not RESOURCE_URL:
        raise ValueError("RESOURCE_URL required for DLQ check")
    
    dlq_url = RESOURCE_URL.replace("Queues", "Queues").replace("Queue", "DLQ", 1)
    
    try:
        logger.info(f"Checking DLQ: {dlq_url}")
        
        # Get queue attributes
        response = sqs_client.get_queue_attributes(
            QueueUrl=dlq_url,
            AttributeNames=["All"]
        )
        
        attrs = response.get("Attributes", {})
        
        dlq_info = {
            "dlq_url": dlq_url,
            "approximate_message_count": int(attrs.get("ApproximateNumberOfMessages", 0)),
            "approximate_not_visible": int(attrs.get("ApproximateNumberOfNotVisibleMessages", 0)),
            "created_timestamp": attrs.get("CreatedTimestamp"),
            "last_modified": attrs.get("LastModifiedTimestamp"),
            "visibility_timeout": attrs.get("VisibilityTimeout")
        }
        
        logger.info(f"DLQ status: {dlq_info}")
        return dlq_info
    
    except ClientError as e:
        logger.error(f"DLQ check failed: {str(e)}")
        raise


def purge_queue() -> Dict[str, Any]:
    """
    Purge all messages from queue (WARNING: deleted permanently).
    
    Returns:
        Purge confirmation
    """
    
    if not RESOURCE_URL:
        raise ValueError("RESOURCE_URL required for purge")
    
    try:
        logger.warning(f"PURGING QUEUE: {RESOURCE_URL}")
        
        sqs_client.purge_queue(QueueUrl=RESOURCE_URL)
        
        logger.warning("Queue purged successfully")
        
        return {
            "queue_url": RESOURCE_URL,
            "status": "purged",
            "timestamp": datetime.now().isoformat(),
            "warning": "All messages in queue have been permanently deleted"
        }
    
    except ClientError as e:
        logger.error(f"Purge failed: {str(e)}")
        raise


def handle_message(message_body: Dict[str, Any]) -> Dict[str, Any]:
    """
    Handle/process a single message.
    
    Args:
        message_body: Parsed message content
    
    Returns:
        Dict with success status and result
    """
    
    try:
        logger.info(f"Handling message: {json.dumps(message_body)}")
        
        # Add your custom message handling logic here
        # Examples: database operations, API calls, data processing, etc.
        
        # For now, just log and return success
        return {
            "success": True,
            "message_type": message_body.get("type", "generic"),
            "processed_at": datetime.now().isoformat()
        }
    
    except Exception as e:
        logger.error(f"Message handling error: {str(e)}")
        return {
            "success": False,
            "error": str(e)
        }


if __name__ == "__main__":
    logger.info("Running SNS/SQS Message Processor in standalone mode")
    result = lambda_handler({})
    print(json.dumps(result, indent=2, default=str))
