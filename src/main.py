from fastmcp import FastMCP
import os
import boto3
from aws_lambda_powertools import Logger

# Initialize Logger
logger = Logger(service="remote-mcp-server")

# Configure logger based on environment
if os.environ.get('AWS_LAMBDA_FUNCTION_NAME'):
    # Running in Lambda - use structured logging
    logger.setLevel(os.environ.get('LOG_LEVEL', 'INFO'))
else:
    # Running locally - use debug level
    logger.setLevel('DEBUG')

mcp = FastMCP(
    "remote-mcp-server",
    stateless_http=True,
    json_response=True
)

# Log MCP server initialization
if os.environ.get('AWS_LAMBDA_FUNCTION_NAME'):
    logger.info("MCP server initialized in Lambda environment", 
                extra={"function_name": os.environ.get('AWS_LAMBDA_FUNCTION_NAME')})
else:
    logger.info("MCP server initialized in development environment")

s3 = boto3.client('s3')

@mcp.tool()
def list_files(bucket: str = None, prefix: str = '') -> list:
    """
    List objects in an S3 bucket under the given prefix.
    """
    # use environment variables if not provided
    bucket_name = bucket or os.environ['BUCKET_NAME']
    prefix_val = prefix
    
    logger.info("Listing S3 objects", extra={
        "bucket": bucket_name,
        "prefix": prefix_val,
        "request_id": os.environ.get('AWS_REQUEST_ID', 'local')
    })
    
    try:
        paginator = s3.get_paginator('list_objects_v2')
        pages = paginator.paginate(Bucket=bucket_name, Prefix=prefix_val)
        keys = []
        for page in pages:
            for obj in page.get('Contents', []):
                if obj['Key'] != prefix_val:
                    keys.append(obj['Key'])
        
        logger.info("Successfully listed S3 objects", extra={
            "bucket": bucket_name,
            "prefix": prefix_val,
            "count": len(keys)
        })
        return keys
    except Exception as e:
        logger.error("Failed to list S3 objects", extra={
            "bucket": bucket_name,
            "prefix": prefix_val,
            "error": str(e)
        }, exc_info=True)
        raise

@mcp.tool()
def add(a: int, b: int) -> int:
    """
    Add two integers.
    """
    logger.info("Performing addition", extra={"a": a, "b": b})
    result = a + b
    logger.info("Addition completed", extra={"result": result})
    return result

@mcp.tool()
def multiply(a: int, b: int) -> int:
    """
    Multiply two integers.
    """
    logger.info("Performing multiplication", extra={"a": a, "b": b})
    result = a * b
    logger.info("Multiplication completed", extra={"result": result})
    return result

if __name__ == "__main__":
    mcp.run(
        transport="streamable-http",
        host="127.0.0.1",
        port=8080,
        path="/mcp",
    )