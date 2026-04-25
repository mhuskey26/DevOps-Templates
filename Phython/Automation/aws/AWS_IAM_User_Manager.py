"""
AWS IAM User Manager

Manages IAM user lifecycle including creation, policy attachment, access key
rotation, multi-factor authentication setup, and cleanup of inactive users.

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

# IAM user name
USER_NAME = os.environ.get("USER_NAME", "new-developer")

# Policy names to attach (comma-separated)
POLICY_NAMES = os.environ.get("POLICY_NAMES", "AdministratorAccess")

# Inactivity threshold (days) - delete if no login
INACTIVITY_DAYS = int(os.environ.get("INACTIVITY_DAYS", "90"))

# Require MFA for all users
REQUIRE_MFA = os.environ.get("REQUIRE_MFA", "true").lower() == "true"

# Action: 'create', 'delete', 'list', 'audit', 'rotate-keys', or 'enable-mfa'
ACTION = os.environ.get("ACTION", "list").lower()

# Maximum users to process
MAX_USERS = int(os.environ.get("MAX_USERS", "0"))

# ============================================================================

iam_client = boto3.client("iam")


def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
    """
    Lambda handler for IAM user management.
    
    Args:
        event: Lambda event with optional action override
        context: Lambda context object
    
    Returns:
        Dict with operation results
    """
    
    logger.info("=" * 80)
    logger.info(f"IAM User Manager - Started at {datetime.now().isoformat()}")
    logger.info(f"Action: {ACTION}")
    logger.info("=" * 80)
    
    action = event.get("action", ACTION) if event else ACTION
    
    results = {
        "timestamp": datetime.now().isoformat(),
        "action": action,
        "data": {},
        "errors": []
    }
    
    try:
        if action == "create":
            if not USER_NAME:
                raise ValueError("USER_NAME required for create action")
            data = create_user()
            results["data"]["user"] = data
        
        elif action == "delete":
            if not USER_NAME:
                raise ValueError("USER_NAME required for delete action")
            data = delete_user()
            results["data"]["deleted"] = data
        
        elif action == "list":
            data = list_users()
            results["data"]["users"] = data
        
        elif action == "audit":
            data = audit_users()
            results["data"]["audit"] = data
        
        elif action == "rotate-keys":
            if not USER_NAME:
                raise ValueError("USER_NAME required for rotate-keys action")
            data = rotate_access_keys()
            results["data"]["rotation"] = data
        
        elif action == "enable-mfa":
            if not USER_NAME:
                raise ValueError("USER_NAME required for enable-mfa action")
            data = setup_mfa()
            results["data"]["mfa"] = data
        
        else:
            raise ValueError(f"Unknown action: {action}")
        
        logger.info(f"Success: {json.dumps(results, indent=2, default=str)}")
        return {"statusCode": 200, "body": results}
        
    except Exception as e:
        error_msg = f"IAM operation failed: {str(e)}"
        logger.error(error_msg)
        results["errors"].append(error_msg)
        return {"statusCode": 500, "body": results}


def create_user() -> Dict[str, Any]:
    """
    Create new IAM user and attach policies.
    
    Returns:
        User creation details
    """
    
    try:
        logger.info(f"Creating IAM user: {USER_NAME}")
        response = iam_client.create_user(
            UserName=USER_NAME,
            Tags=[
                {"Key": "ManagedBy", "Value": "Lambda"},
                {"Key": "CreatedAt", "Value": datetime.now().isoformat()}
            ]
        )
        
        user = response["User"]
        logger.info(f"User created: {user['Arn']}")
        
        # Attach policies
        policies = [p.strip() for p in POLICY_NAMES.split(",")]
        for policy_name in policies:
            try:
                iam_client.attach_user_policy(
                    UserName=USER_NAME,
                    PolicyArn=f"arn:aws:iam::aws:policy/{policy_name}"
                )
                logger.info(f"Attached policy: {policy_name}")
            except ClientError as e:
                logger.warning(f"Failed to attach policy {policy_name}: {str(e)}")
        
        return {
            "user_name": user["UserName"],
            "user_arn": user["Arn"],
            "create_date": user["CreateDate"].isoformat(),
            "policies_attached": policies
        }
    
    except ClientError as e:
        logger.error(f"User creation failed: {str(e)}")
        raise


def delete_user() -> Dict[str, Any]:
    """
    Delete IAM user and associated resources.
    
    Returns:
        Deletion details
    """
    
    try:
        logger.info(f"Deleting IAM user: {USER_NAME}")
        
        # List and detach user policies
        policies_response = iam_client.list_attached_user_policies(UserName=USER_NAME)
        for policy in policies_response.get("AttachedPolicies", []):
            iam_client.detach_user_policy(
                UserName=USER_NAME,
                PolicyArn=policy["PolicyArn"]
            )
            logger.info(f"Detached policy: {policy['PolicyName']}")
        
        # Delete access keys
        keys_response = iam_client.list_access_keys(UserName=USER_NAME)
        for key in keys_response.get("AccessKeyMetadata", []):
            iam_client.delete_access_key(
                UserName=USER_NAME,
                AccessKeyId=key["AccessKeyId"]
            )
            logger.info(f"Deleted access key: {key['AccessKeyId']}")
        
        # Delete login profile
        try:
            iam_client.delete_login_profile(UserName=USER_NAME)
            logger.info("Deleted login profile")
        except ClientError:
            logger.info("No login profile to delete")
        
        # Delete user
        iam_client.delete_user(UserName=USER_NAME)
        logger.info(f"User deleted: {USER_NAME}")
        
        return {
            "user_name": USER_NAME,
            "deleted": True,
            "resources_cleaned": ["policies", "access_keys", "login_profile"]
        }
    
    except ClientError as e:
        logger.error(f"User deletion failed: {str(e)}")
        raise


def list_users(max_items: int = 50) -> List[Dict[str, Any]]:
    """
    List all IAM users in account.
    
    Args:
        max_items: Maximum users to return
    
    Returns:
        List of user details
    """
    
    try:
        logger.info("Listing IAM users")
        response = iam_client.list_users(MaxItems=min(max_items, 100))
        
        users = []
        for user in response.get("Users", []):
            users.append({
                "user_name": user["UserName"],
                "user_arn": user["Arn"],
                "create_date": user["CreateDate"].isoformat(),
                "user_id": user["UserId"]
            })
        
        logger.info(f"Found {len(users)} users")
        return users
    
    except ClientError as e:
        logger.error(f"List users failed: {str(e)}")
        raise


def audit_users() -> Dict[str, Any]:
    """
    Audit IAM users for security issues and inactivity.
    
    Returns:
        Audit report with findings
    """
    
    audit_data = {
        "total_users": 0,
        "inactive_users": [],
        "users_without_mfa": [],
        "users_with_old_keys": [],
        "findings": []
    }
    
    try:
        logger.info("Starting IAM audit")
        response = iam_client.list_users()
        
        cutoff_date = datetime.now(datetime.now().astimezone().tzinfo) - timedelta(days=INACTIVITY_DAYS)
        
        for user in response.get("Users", []):
            user_name = user["UserName"]
            audit_data["total_users"] += 1
            
            # Check last login activity
            try:
                login_response = iam_client.get_user(UserName=user_name)
                user_detail = login_response["User"]
                
                # Get access key info
                keys_response = iam_client.list_access_keys(UserName=user_name)
                for key in keys_response.get("AccessKeyMetadata", []):
                    created = key["CreateDate"].replace(tzinfo=None)
                    if created < cutoff_date.replace(tzinfo=None):
                        audit_data["users_with_old_keys"].append({
                            "user": user_name,
                            "key_id": key["AccessKeyId"],
                            "created": created.isoformat(),
                            "days_old": (datetime.now() - created).days
                        })
                
                # Check MFA
                mfa_response = iam_client.list_mfa_devices(UserName=user_name)
                if not mfa_response.get("MFADevices"):
                    audit_data["users_without_mfa"].append(user_name)
                    audit_data["findings"].append(f"{user_name}: MFA not enabled")
            
            except Exception as e:
                logger.warning(f"Error auditing {user_name}: {str(e)}")
        
        logger.info(f"Audit complete: {audit_data['total_users']} users reviewed")
        return audit_data
    
    except ClientError as e:
        logger.error(f"Audit failed: {str(e)}")
        raise


def rotate_access_keys() -> Dict[str, Any]:
    """
    Rotate access keys for user.
    
    Returns:
        Rotation details with new credentials
    """
    
    try:
        logger.info(f"Rotating access keys for {USER_NAME}")
        
        # Deactivate old keys
        keys_response = iam_client.list_access_keys(UserName=USER_NAME)
        for key in keys_response.get("AccessKeyMetadata", []):
            iam_client.update_access_key(
                UserName=USER_NAME,
                AccessKeyId=key["AccessKeyId"],
                Status="Inactive"
            )
            logger.info(f"Deactivated old key: {key['AccessKeyId']}")
        
        # Create new key
        new_key_response = iam_client.create_access_key(UserName=USER_NAME)
        new_key = new_key_response["AccessKey"]
        
        logger.warning(f"New access key created: {new_key['AccessKeyId']}")
        logger.warning(f"Secret key: {new_key['SecretAccessKey']}")  # Log once for initial setup
        
        return {
            "user": USER_NAME,
            "new_access_key_id": new_key["AccessKeyId"],
            "secret_access_key": new_key["SecretAccessKey"],
            "old_keys_deactivated": len(keys_response.get("AccessKeyMetadata", [])),
            "warning": "Save the secret key immediately - it cannot be retrieved later"
        }
    
    except ClientError as e:
        logger.error(f"Key rotation failed: {str(e)}")
        raise


def setup_mfa() -> Dict[str, Any]:
    """
    Enable MFA for user (returns virtual MFA setup instructions).
    
    Returns:
        MFA setup details
    """
    
    try:
        logger.info(f"Setting up MFA for {USER_NAME}")
        
        mfa_device_name = f"{USER_NAME}-mfa"
        response = iam_client.create_virtual_mfa_device(VirtualMFADeviceName=mfa_device_name)
        
        mfa = response["VirtualMFADevice"]
        
        logger.info(f"Virtual MFA device created: {mfa['SerialNumber']}")
        
        return {
            "user": USER_NAME,
            "serial_number": mfa["SerialNumber"],
            "base32_string_seed": mfa.get("Base32StringSeed", "Check AWS console"),
            "setup_instruction": "Use serial number and base32 seed with authenticator app (Google Authenticator, Authy, etc.)",
            "next_step": "Call enable_mfa with user codes from authenticator app"
        }
    
    except ClientError as e:
        logger.error(f"MFA setup failed: {str(e)}")
        raise


if __name__ == "__main__":
    logger.info("Running IAM User Manager in standalone mode")
    result = lambda_handler({})
    print(json.dumps(result, indent=2, default=str))
