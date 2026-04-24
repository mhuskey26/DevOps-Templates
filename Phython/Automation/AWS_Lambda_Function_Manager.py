"""
AWS Lambda Function Manager

Manages Lambda function lifecycle including deployment, environment variables,
layer management, alias management, and version control.

Author: DevOps Team
Version: 1.0
"""

import json
import logging
import os
import zipfile
from datetime import datetime
from io import BytesIO
from pathlib import Path
from typing import Any, Dict, List, Optional

import boto3
from botocore.exceptions import ClientError

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# ============================================================================
# CONFIGURABLE VARIABLES
# ============================================================================

# Lambda function name
FUNCTION_NAME = os.environ.get("FUNCTION_NAME", "my-function")

# AWS region
REGION = os.environ.get("AWS_REGION", "us-east-1")

# IAM role ARN for Lambda
ROLE_ARN = os.environ.get("ROLE_ARN", "arn:aws:iam::ACCOUNT:role/lambda-execution-role")

# Runtime (python3.11, python3.12, nodejs18.x, nodejs20.x, etc.)
RUNTIME = os.environ.get("RUNTIME", "python3.11")

# Handler (for Python: module.function_name)
HANDLER = os.environ.get("HANDLER", "lambda_function.lambda_handler")

# Memory (128-10240 MB)
MEMORY_SIZE = int(os.environ.get("MEMORY_SIZE", "256"))

# Timeout (1-900 seconds)
TIMEOUT = int(os.environ.get("TIMEOUT", "60"))

# Path to function code (zip file or directory)
CODE_PATH = os.environ.get("CODE_PATH", "")

# Environment variables (JSON format)
ENVIRONMENT_VARS = os.environ.get("ENVIRONMENT_VARS", "{}")

# Action: 'create', 'update', 'deploy', 'invoke', 'list', 'delete-version', or 'alias'
ACTION = os.environ.get("ACTION", "list").lower()

# Version alias name (for alias operations)
ALIAS_NAME = os.environ.get("ALIAS_NAME", "live")

# Version number to alias
VERSION_NUMBER = os.environ.get("VERSION_NUMBER", "")

# ============================================================================

lambda_client = boto3.client("lambda", region_name=REGION)


def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
    """
    Lambda handler for Lambda function management.
    
    Args:
        event: Lambda event with optional action override
        context: Lambda context object
    
    Returns:
        Dict with operation results
    """
    
    logger.info("=" * 80)
    logger.info(f"Lambda Function Manager - Started at {datetime.now().isoformat()}")
    logger.info(f"Function: {FUNCTION_NAME}, Action: {ACTION}")
    logger.info("=" * 80)
    
    action = event.get("action", ACTION) if event else ACTION
    
    results = {
        "timestamp": datetime.now().isoformat(),
        "action": action,
        "function": FUNCTION_NAME,
        "data": {},
        "errors": []
    }
    
    try:
        if action == "create":
            if not CODE_PATH:
                raise ValueError("CODE_PATH required for create action")
            data = create_function()
            results["data"]["function"] = data
        
        elif action == "update":
            if not CODE_PATH:
                raise ValueError("CODE_PATH required for update action")
            data = update_function_code()
            results["data"]["update"] = data
        
        elif action == "deploy":
            if not CODE_PATH:
                raise ValueError("CODE_PATH required for deploy action")
            data = deploy_new_version()
            results["data"]["deployment"] = data
        
        elif action == "invoke":
            data = invoke_function()
            results["data"]["invocation"] = data
        
        elif action == "list":
            data = list_versions()
            results["data"]["versions"] = data
        
        elif action == "delete-version":
            if not VERSION_NUMBER:
                raise ValueError("VERSION_NUMBER required for delete-version action")
            data = delete_version()
            results["data"]["deleted"] = data
        
        elif action == "alias":
            if not VERSION_NUMBER or not ALIAS_NAME:
                raise ValueError("VERSION_NUMBER and ALIAS_NAME required for alias action")
            data = update_alias()
            results["data"]["alias"] = data
        
        else:
            raise ValueError(f"Unknown action: {action}")
        
        logger.info(f"Success: {json.dumps(results, indent=2, default=str)}")
        return {"statusCode": 200, "body": results}
        
    except Exception as e:
        error_msg = f"Lambda operation failed: {str(e)}"
        logger.error(error_msg)
        results["errors"].append(error_msg)
        return {"statusCode": 500, "body": results}


def create_function() -> Dict[str, Any]:
    """
    Create new Lambda function.
    
    Returns:
        Function details
    """
    
    try:
        logger.info(f"Creating Lambda function: {FUNCTION_NAME}")
        
        # Read and zip code
        code_zip = create_zip_file(CODE_PATH)
        
        env_vars = json.loads(ENVIRONMENT_VARS)
        
        response = lambda_client.create_function(
            FunctionName=FUNCTION_NAME,
            Runtime=RUNTIME,
            Role=ROLE_ARN,
            Handler=HANDLER,
            Code={"ZipFile": code_zip},
            Timeout=TIMEOUT,
            MemorySize=MEMORY_SIZE,
            Environment={"Variables": env_vars} if env_vars else {},
            Tags={
                "ManagedBy": "Lambda",
                "CreatedAt": datetime.now().isoformat()
            }
        )
        
        func = response
        logger.info(f"Function created: {func['FunctionArn']}")
        
        return {
            "function_name": func["FunctionName"],
            "function_arn": func["FunctionArn"],
            "runtime": func["Runtime"],
            "handler": func["Handler"],
            "code_sha256": func["CodeSha256"],
            "version": func["Version"]
        }
    
    except ClientError as e:
        logger.error(f"Function creation failed: {str(e)}")
        raise


def update_function_code() -> Dict[str, Any]:
    """
    Update Lambda function code.
    
    Returns:
        Update details
    """
    
    try:
        logger.info(f"Updating code for {FUNCTION_NAME}")
        
        code_zip = create_zip_file(CODE_PATH)
        
        response = lambda_client.update_function_code(
            FunctionName=FUNCTION_NAME,
            ZipFile=code_zip
        )
        
        func = response
        logger.info(f"Code updated: {func['CodeSha256']}")
        
        return {
            "function_name": func["FunctionName"],
            "code_sha256": func["CodeSha256"],
            "version": func["Version"],
            "last_modified": func["LastModified"]
        }
    
    except ClientError as e:
        logger.error(f"Code update failed: {str(e)}")
        raise


def deploy_new_version() -> Dict[str, Any]:
    """
    Deploy new function version and optionally update alias.
    
    Returns:
        Deployment details
    """
    
    try:
        logger.info(f"Deploying new version of {FUNCTION_NAME}")
        
        # Update code
        code_update = update_function_code()
        
        # Publish new version
        publish_response = lambda_client.publish_version(
            FunctionName=FUNCTION_NAME,
            Description=f"Deployed at {datetime.now().isoformat()}"
        )
        
        new_version = publish_response["Version"]
        logger.info(f"New version published: {new_version}")
        
        # Update alias if specified
        if ALIAS_NAME:
            try:
                lambda_client.update_alias(
                    FunctionName=FUNCTION_NAME,
                    Name=ALIAS_NAME,
                    FunctionVersion=new_version
                )
                logger.info(f"Alias {ALIAS_NAME} updated to version {new_version}")
            except ClientError as e:
                if "ResourceNotFoundException" in str(e):
                    logger.info(f"Creating alias {ALIAS_NAME}")
                    lambda_client.create_alias(
                        FunctionName=FUNCTION_NAME,
                        Name=ALIAS_NAME,
                        FunctionVersion=new_version
                    )
        
        return {
            "function_name": FUNCTION_NAME,
            "new_version": new_version,
            "code_sha256": code_update["code_sha256"],
            "alias_updated": ALIAS_NAME,
            "timestamp": datetime.now().isoformat()
        }
    
    except ClientError as e:
        logger.error(f"Deployment failed: {str(e)}")
        raise


def invoke_function(test_payload: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
    """
    Invoke Lambda function with test payload.
    
    Args:
        test_payload: Test data to send to function
    
    Returns:
        Invocation result
    """
    
    test_payload = test_payload or {"test": True}
    
    try:
        logger.info(f"Invoking {FUNCTION_NAME} with payload: {json.dumps(test_payload)}")
        
        response = lambda_client.invoke(
            FunctionName=FUNCTION_NAME,
            InvocationType="RequestResponse",
            LogType="Tail",
            Payload=json.dumps(test_payload)
        )
        
        status = response["StatusCode"]
        log_result = response.get("LogResult", "")
        
        # Decode and parse payload
        payload = response.get("Payload")
        if hasattr(payload, "read"):
            payload_str = payload.read().decode("utf-8")
        else:
            payload_str = str(payload)
        
        logger.info(f"Invocation status: {status}")
        logger.info(f"Response: {payload_str}")
        
        return {
            "function": FUNCTION_NAME,
            "status_code": status,
            "response": payload_str,
            "logs": log_result,
            "invoked_at": datetime.now().isoformat()
        }
    
    except ClientError as e:
        logger.error(f"Invocation failed: {str(e)}")
        raise


def list_versions() -> List[Dict[str, Any]]:
    """
    List all versions of Lambda function.
    
    Returns:
        List of versions
    """
    
    try:
        logger.info(f"Listing versions for {FUNCTION_NAME}")
        
        response = lambda_client.list_versions_by_function(FunctionName=FUNCTION_NAME)
        
        versions = []
        for version in response.get("Versions", []):
            versions.append({
                "version": version["Version"],
                "code_sha256": version["CodeSha256"],
                "memory": version["MemorySize"],
                "runtime": version["Runtime"],
                "last_modified": version["LastModified"],
                "description": version.get("Description", "")
            })
        
        # List aliases
        aliases_response = lambda_client.list_aliases(FunctionName=FUNCTION_NAME)
        aliases = {
            alias["Name"]: alias["FunctionVersion"]
            for alias in aliases_response.get("Aliases", [])
        }
        
        logger.info(f"Found {len(versions)} versions, {len(aliases)} aliases")
        
        return {
            "versions": versions,
            "aliases": aliases
        }
    
    except ClientError as e:
        logger.error(f"List versions failed: {str(e)}")
        raise


def delete_version() -> Dict[str, Any]:
    """
    Delete specific Lambda function version.
    
    Returns:
        Deletion confirmation
    """
    
    try:
        logger.info(f"Deleting version {VERSION_NUMBER} of {FUNCTION_NAME}")
        
        lambda_client.delete_function(
            FunctionName=FUNCTION_NAME,
            Qualifier=VERSION_NUMBER
        )
        
        logger.info(f"Version {VERSION_NUMBER} deleted")
        
        return {
            "function": FUNCTION_NAME,
            "version": VERSION_NUMBER,
            "deleted": True,
            "timestamp": datetime.now().isoformat()
        }
    
    except ClientError as e:
        logger.error(f"Delete failed: {str(e)}")
        raise


def update_alias() -> Dict[str, Any]:
    """
    Update or create function alias pointing to specific version.
    
    Returns:
        Alias details
    """
    
    try:
        logger.info(f"Updating alias {ALIAS_NAME} to version {VERSION_NUMBER}")
        
        try:
            response = lambda_client.update_alias(
                FunctionName=FUNCTION_NAME,
                Name=ALIAS_NAME,
                FunctionVersion=VERSION_NUMBER
            )
            action = "updated"
        except ClientError as e:
            if "ResourceNotFoundException" in str(e):
                response = lambda_client.create_alias(
                    FunctionName=FUNCTION_NAME,
                    Name=ALIAS_NAME,
                    FunctionVersion=VERSION_NUMBER
                )
                action = "created"
            else:
                raise
        
        alias = response
        logger.info(f"Alias {action}: {alias['AliasArn']}")
        
        return {
            "function": FUNCTION_NAME,
            "alias_name": alias["Name"],
            "version": alias["FunctionVersion"],
            "alias_arn": alias["AliasArn"],
            "action": action
        }
    
    except ClientError as e:
        logger.error(f"Alias operation failed: {str(e)}")
        raise


def create_zip_file(path: str) -> bytes:
    """
    Create ZIP file from code path (file or directory).
    
    Args:
        path: Path to Python file or directory
    
    Returns:
        ZIP file as bytes
    """
    
    if not path:
        raise ValueError("CODE_PATH must be specified")
    
    if not os.path.exists(path):
        raise FileNotFoundError(f"Code path not found: {path}")
    
    zip_buffer = BytesIO()
    
    with zipfile.ZipFile(zip_buffer, "w", zipfile.ZIP_DEFLATED) as zip_file:
        if os.path.isfile(path):
            # Single file
            zip_file.write(path, arcname=os.path.basename(path))
            logger.info(f"Added file: {path}")
        else:
            # Directory
            for root, dirs, files in os.walk(path):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, path)
                    zip_file.write(file_path, arcname=arcname)
                    logger.info(f"Added file: {arcname}")
    
    zip_buffer.seek(0)
    return zip_buffer.read()


if __name__ == "__main__":
    logger.info("Running Lambda Function Manager in standalone mode")
    result = lambda_handler({})
    print(json.dumps(result, indent=2, default=str))
