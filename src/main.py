from fastmcp import FastMCP
import os
import boto3

mcp = FastMCP(json_response=True)
s3 = boto3.client('s3')

@mcp.tool()
def list_files(bucket: str = None, prefix: str = '') -> list:
    """
    List objects in an S3 bucket under the given prefix.
    """
    # use environment variables if not provided
    bucket_name = bucket or os.environ['BUCKET_NAME']
    prefix_val = prefix
    paginator = s3.get_paginator('list_objects_v2')
    pages = paginator.paginate(Bucket=bucket_name, Prefix=prefix_val)
    keys = []
    for page in pages:
        for obj in page.get('Contents', []):
            if obj['Key'] != prefix_val:
                keys.append(obj['Key'])
    return keys

@mcp.tool()
def add(a: int, b: int) -> int:
    """
    Add two integers.
    """
    return a + b

@mcp.tool()
def multiply(a: int, b: int) -> int:
    """
    Multiply two integers.
    """
    return a * b

app = mcp.http_app()

if __name__ == "__main__":
    mcp.run(
        transport="streamable-http",
        host="0.0.0.0",
        port=8080,
        path="/",             # ルート提供
        log_level="critical",
    )