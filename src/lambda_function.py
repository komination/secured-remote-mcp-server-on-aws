import os
import json
import boto3

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket = os.environ['BUCKET_NAME']
    prefix = os.environ.get('PREFIX', '')
    
    paginator = s3.get_paginator('list_objects_v2')
    page_iterator = paginator.paginate(Bucket=bucket, Prefix=prefix)
    
    keys = []
    for page in page_iterator:
        for obj in page.get('Contents', []):
            if obj['Key'] != prefix:
                keys.append(obj['Key'])
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'files': keys
        })
    }
