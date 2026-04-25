"""
AWS CloudWatch Logs Analyzer

Analyzes CloudWatch logs to extract metrics, search for errors, generate
reports, and trigger alerts based on patterns.

Author: DevOps Team
Version: 1.0
"""

import json
import logging
import os
import re
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

# CloudWatch log group name
LOG_GROUP_NAME = os.environ.get("LOG_GROUP_NAME", "/aws/lambda/my-function")

# Time period to analyze (minutes, default = last hour)
LOOKBACK_MINUTES = int(os.environ.get("LOOKBACK_MINUTES", "60"))

# Search pattern (CloudWatch Insights query)
SEARCH_PATTERN = os.environ.get(
    "SEARCH_PATTERN",
    "fields @timestamp, @message, @duration | filter @message like /ERROR/"
)

# Action: 'search', 'metrics', 'errors', or 'insights'
ACTION = os.environ.get("ACTION", "search").lower()

# Maximum results
MAX_RESULTS = int(os.environ.get("MAX_RESULTS", "100"))

# ============================================================================

logs_client = boto3.client("logs")
cloudwatch_client = boto3.client("cloudwatch")


def lambda_handler(event: Dict[str, Any], context: Any = None) -> Dict[str, Any]:
    """
    Lambda handler for CloudWatch log analysis.
    
    Args:
        event: Lambda event with optional parameters
        context: Lambda context object
    
    Returns:
        Dict with analysis results
    """
    
    logger.info("=" * 80)
    logger.info(f"CloudWatch Logs Analyzer - Started at {datetime.now().isoformat()}")
    logger.info(f"Log Group: {LOG_GROUP_NAME}, Action: {ACTION}")
    logger.info("=" * 80)
    
    action = event.get("action", ACTION) if event else ACTION
    
    results = {
        "timestamp": datetime.now().isoformat(),
        "action": action,
        "log_group": LOG_GROUP_NAME,
        "lookback_minutes": LOOKBACK_MINUTES,
        "data": {},
        "errors": []
    }
    
    try:
        if action == "search":
            data = search_logs()
            results["data"]["matches"] = data
        
        elif action == "metrics":
            data = extract_metrics()
            results["data"]["metrics"] = data
        
        elif action == "errors":
            data = find_errors()
            results["data"]["errors"] = data
        
        elif action == "insights":
            data = run_insights_query()
            results["data"]["query_results"] = data
        
        else:
            raise ValueError(f"Unknown action: {action}")
        
        logger.info(f"Success: {json.dumps(results, indent=2)}")
        return {"statusCode": 200, "body": results}
        
    except Exception as e:
        error_msg = f"Log analysis failed: {str(e)}"
        logger.error(error_msg)
        results["errors"].append(error_msg)
        return {"statusCode": 500, "body": results}


def search_logs(pattern: Optional[str] = None) -> List[Dict[str, Any]]:
    """
    Search log group for pattern.
    
    Args:
        pattern: Grep-style search pattern
    
    Returns:
        List of matching log events
    """
    
    pattern = pattern or SEARCH_PATTERN
    start_time = int((datetime.now() - timedelta(minutes=LOOKBACK_MINUTES)).timestamp() * 1000)
    end_time = int(datetime.now().timestamp() * 1000)
    
    try:
        logger.info(f"Searching logs for pattern: {pattern}")
        response = logs_client.filter_log_events(
            logGroupName=LOG_GROUP_NAME,
            startTime=start_time,
            endTime=end_time,
            filterPattern=pattern,
            limit=MAX_RESULTS
        )
        
        matches = []
        for event in response.get("events", []):
            matches.append({
                "timestamp": datetime.fromtimestamp(event["timestamp"] / 1000).isoformat(),
                "message": event["message"],
                "log_stream": event.get("logStreamName")
            })
        
        logger.info(f"Found {len(matches)} matches")
        return matches
    
    except ClientError as e:
        logger.error(f"Search failed: {str(e)}")
        raise


def extract_metrics() -> Dict[str, Any]:
    """
    Extract metrics from logs (response times, counts, etc.).
    
    Returns:
        Dict with extracted metrics
    """
    
    start_time = int((datetime.now() - timedelta(minutes=LOOKBACK_MINUTES)).timestamp() * 1000)
    end_time = int(datetime.now().timestamp() * 1000)
    
    metrics = {
        "total_events": 0,
        "log_streams": set(),
        "response_times": [],
        "request_counts": 0
    }
    
    try:
        logger.info("Extracting metrics from logs")
        response = logs_client.filter_log_events(
            logGroupName=LOG_GROUP_NAME,
            startTime=start_time,
            endTime=end_time,
            limit=MAX_RESULTS
        )
        
        for event in response.get("events", []):
            metrics["total_events"] += 1
            metrics["log_streams"].add(event.get("logStreamName", "unknown"))
            
            # Try to extract response time using regex
            match = re.search(r"duration[\"']?\s*[:\=]\s*(\d+\.?\d*)", event["message"], re.I)
            if match:
                duration = float(match.group(1))
                metrics["response_times"].append(duration)
            
            # Count requests
            if "request" in event["message"].lower():
                metrics["request_counts"] += 1
        
        # Calculate response time statistics
        if metrics["response_times"]:
            metrics["avg_duration"] = sum(metrics["response_times"]) / len(metrics["response_times"])
            metrics["max_duration"] = max(metrics["response_times"])
            metrics["min_duration"] = min(metrics["response_times"])
        
        metrics["unique_streams"] = len(metrics["log_streams"])
        del metrics["log_streams"]  # Remove set before JSON serialization
        
        logger.info(f"Metrics extracted: {len(metrics)} metrics")
        return metrics
    
    except Exception as e:
        logger.error(f"Metric extraction failed: {str(e)}")
        raise


def find_errors() -> List[Dict[str, Any]]:
    """
    Find and categorize errors in logs.
    
    Returns:
        List of errors with context
    """
    
    start_time = int((datetime.now() - timedelta(minutes=LOOKBACK_MINUTES)).timestamp() * 1000)
    end_time = int(datetime.now().timestamp() * 1000)
    
    error_patterns = {
        "error": r"\[ERROR\]|error:|Exception|Error:",
        "warning": r"\[WARNING\]|warning:|Warn:",
        "critical": r"\[CRITICAL\]|FATAL|OutOfMemory|SegmentationFault"
    }
    
    errors_by_type = {error_type: [] for error_type in error_patterns}
    
    try:
        logger.info("Searching for errors")
        response = logs_client.filter_log_events(
            logGroupName=LOG_GROUP_NAME,
            startTime=start_time,
            endTime=end_time,
            limit=MAX_RESULTS * 2
        )
        
        for event in response.get("events", []):
            message = event["message"]
            
            for error_type, pattern in error_patterns.items():
                if re.search(pattern, message, re.I):
                    errors_by_type[error_type].append({
                        "timestamp": datetime.fromtimestamp(event["timestamp"] / 1000).isoformat(),
                        "message": message[:200],  # Truncate long messages
                        "stream": event.get("logStreamName")
                    })
                    break  # Only categorize once
        
        # Count errors
        total_errors = sum(len(v) for v in errors_by_type.values())
        logger.info(f"Found {total_errors} errors")
        
        return errors_by_type
    
    except Exception as e:
        logger.error(f"Error search failed: {str(e)}")
        raise


def run_insights_query() -> List[Dict[str, Any]]:
    """
    Run CloudWatch Insights query.
    
    Returns:
        Query results
    """
    
    start_time = int((datetime.now() - timedelta(minutes=LOOKBACK_MINUTES)).timestamp())
    end_time = int(datetime.now().timestamp())
    
    try:
        logger.info(f"Running Insights query: {SEARCH_PATTERN}")
        
        # Start query
        query_response = logs_client.start_query(
            logGroupName=LOG_GROUP_NAME,
            startTime=start_time,
            endTime=end_time,
            queryString=SEARCH_PATTERN
        )
        
        query_id = query_response["queryId"]
        logger.info(f"Query ID: {query_id}")
        
        # Poll for results
        import time
        max_attempts = 30
        attempt = 0
        
        while attempt < max_attempts:
            result_response = logs_client.get_query_results(queryId=query_id)
            status = result_response["status"]
            
            if status == "Complete":
                logger.info("Query completed")
                return result_response.get("results", [])[:MAX_RESULTS]
            
            if status == "Failed":
                raise Exception(f"Query failed: {result_response.get('statistics', {})}")
            
            logger.debug(f"Query status: {status}, waiting...")
            time.sleep(1)
            attempt += 1
        
        raise TimeoutError("Query timed out after 30 seconds")
    
    except ClientError as e:
        logger.error(f"Query failed: {str(e)}")
        raise


if __name__ == "__main__":
    logger.info("Running CloudWatch Logs Analyzer in standalone mode")
    result = lambda_handler({})
    print(json.dumps(result, indent=2, default=str))
