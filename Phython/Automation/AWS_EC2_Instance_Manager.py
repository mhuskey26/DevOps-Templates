"""
AWS EC2 Instance Manager

Automates EC2 instance lifecycle management including starting, stopping,
terminating, status monitoring, and automated scheduling based on tags.

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

# AWS region
REGION = os.environ.get("AWS_REGION", "us-east-1")

# Filter tag key for targeting instances (e.g., 'Environment' or 'ManagedBy')
FILTER_TAG_KEY = os.environ.get("FILTER_TAG_KEY", "Environment")
FILTER_TAG_VALUE = os.environ.get("FILTER_TAG_VALUE", "dev")

# Actions: 'start', 'stop', 'terminate', 'reboot', or 'status'
ACTION = os.environ.get("ACTION", "status").lower()

# Maximum instances to process per run (0 = no limit)
MAX_INSTANCES = int(os.environ.get("MAX_INSTANCES", "0"))

# Force termination (skip stopping first)
FORCE_TERMINATE = os.environ.get("FORCE_TERMINATE", "false").lower() == "true"

# ============================================================================

ec2_client = boto3.client("ec2", region_name=REGION)
ec2_resource = boto3.resource("ec2", region_name=REGION)


def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
    """
    Lambda handler for EC2 instance management.
    
    Args:
        event: Lambda event with optional action override
        context: Lambda context object
    
    Returns:
        Dict with operation results
    """
    
    logger.info("=" * 80)
    logger.info(f"EC2 Instance Manager - Started at {datetime.now().isoformat()}")
    logger.info(f"Action: {ACTION}, Filter: {FILTER_TAG_KEY}={FILTER_TAG_VALUE}")
    logger.info("=" * 80)
    
    action = event.get("action", ACTION) if event else ACTION
    
    results = {
        "timestamp": datetime.now().isoformat(),
        "action": action,
        "instances_processed": 0,
        "instances": [],
        "errors": []
    }
    
    try:
        # Get instances matching filter
        instances = get_instances_by_tag(FILTER_TAG_KEY, FILTER_TAG_VALUE)
        logger.info(f"Found {len(instances)} instances")
        
        if not instances:
            logger.info("No instances matching filter")
            return {"statusCode": 200, "body": results}
        
        # Process instances
        count = 0
        for instance in instances:
            if MAX_INSTANCES > 0 and count >= MAX_INSTANCES:
                logger.info(f"Reached max instances limit: {MAX_INSTANCES}")
                break
            
            try:
                result = process_instance(instance, action)
                results["instances"].append(result)
                results["instances_processed"] += 1
                count += 1
            except Exception as e:
                error_msg = f"Error processing {instance.id}: {str(e)}"
                logger.error(error_msg)
                results["errors"].append(error_msg)
        
        logger.info(f"Success: {json.dumps(results, indent=2)}")
        return {"statusCode": 200, "body": results}
        
    except Exception as e:
        error_msg = f"Instance management failed: {str(e)}"
        logger.error(error_msg)
        results["errors"].append(error_msg)
        return {"statusCode": 500, "body": results}


def get_instances_by_tag(tag_key: str, tag_value: str) -> List[Any]:
    """
    Get EC2 instances filtered by tag.
    
    Args:
        tag_key: Tag key to filter by
        tag_value: Tag value to match
    
    Returns:
        List of EC2 instance objects
    """
    
    try:
        instances = ec2_resource.instances.filter(
            Filters=[
                {"Name": f"tag:{tag_key}", "Values": [tag_value]},
                {"Name": "instance-state-name", "Values": ["running", "stopped"]}
            ]
        )
        return list(instances)
    except ClientError as e:
        logger.error(f"Failed to query instances: {str(e)}")
        raise


def process_instance(instance: Any, action: str) -> Dict[str, Any]:
    """
    Perform action on EC2 instance.
    
    Args:
        instance: EC2 instance object
        action: Action to perform (start, stop, terminate, reboot, status)
    
    Returns:
        Dict with instance details and operation result
    """
    
    instance.reload()
    instance_info = get_instance_info(instance)
    
    logger.info(f"Processing {instance.id} ({instance.instance_type})")
    logger.info(f"Current state: {instance.state['Name']}")
    
    # Perform action
    if action == "start":
        if instance.state["Name"] == "stopped":
            instance.start()
            logger.info(f"Started instance {instance.id}")
        else:
            logger.info(f"Instance {instance.id} already running")
    
    elif action == "stop":
        if instance.state["Name"] == "running":
            instance.stop()
            logger.info(f"Stopped instance {instance.id}")
        else:
            logger.info(f"Instance {instance.id} already stopped")
    
    elif action == "terminate":
        if FORCE_TERMINATE:
            instance.terminate()
            logger.info(f"Force terminated instance {instance.id}")
        else:
            instance.stop()
            logger.info(f"Stopping instance {instance.id} before termination")
    
    elif action == "reboot":
        if instance.state["Name"] == "running":
            instance.reboot()
            logger.info(f"Rebooted instance {instance.id}")
        else:
            logger.info(f"Cannot reboot stopped instance {instance.id}")
    
    elif action == "status":
        logger.info(f"Instance {instance.id} status: {instance.state['Name']}")
    
    else:
        raise ValueError(f"Unknown action: {action}")
    
    instance_info["action_result"] = action
    return instance_info


def get_instance_info(instance: Any) -> Dict[str, Any]:
    """Extract instance information."""
    
    return {
        "instance_id": instance.id,
        "instance_type": instance.instance_type,
        "state": instance.state["Name"],
        "launch_time": instance.launch_time.isoformat() if instance.launch_time else None,
        "public_ip": instance.public_ip_address,
        "private_ip": instance.private_ip_address,
        "tags": {tag["Key"]: tag["Value"] for tag in (instance.tags or [])}
    }


if __name__ == "__main__":
    logger.info("Running EC2 Instance Manager in standalone mode")
    result = lambda_handler({})
    print(json.dumps(result, indent=2))
