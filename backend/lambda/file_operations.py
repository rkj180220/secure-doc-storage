import boto3
import json
import os
from datetime import datetime
from base64 import b64decode

s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])


def lambda_handler(event, context):
    http_method = event['httpMethod']

    if http_method == 'POST':
        return upload_file(event)
    elif http_method == 'GET':
        return list_files(event)
    elif http_method == 'DELETE':
        return delete_file(event)
    elif http_method == 'PUT':
        return update_file(event)
    else:
        return {
            'statusCode': 400,
            'body': json.dumps('Invalid HTTP method')
        }


def upload_file(event):
    body = json.loads(event['body'])
    file_content = b64decode(body['file'])  # Assuming file content is base64 encoded
    file_name = body['fileName']
    file_type = body['fileType']
    file_size = len(file_content)  # Calculate file size in bytes
    user_id = body['userId']

    # Upload to S3
    s3_client.put_object(
        Bucket=os.environ['S3_BUCKET'],
        Key=file_name,
        Body=file_content,
        ContentType=file_type
    )

    # Store metadata in DynamoDB
    table.put_item(
        Item={
            'FileID': file_name,  # S3 file path
            'UserID': user_id,  # Owner of the file
            'FileType': file_type,  # e.g., .pdf, .jpg
            'FileSize': file_size,  # Size of the file in bytes
            'Timestamp': str(datetime.utcnow())  # Timestamp of the upload
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps(f"File {file_name} uploaded successfully")
    }


def list_files(event):
    user_id = event['queryStringParameters']['userId']

    # Query files by user from DynamoDB
    response = table.query(
        KeyConditionExpression=Key('UserID').eq(user_id)
    )

    return {
        'statusCode': 200,
        'body': json.dumps(response['Items'])
    }


def delete_file(event):
    body = json.loads(event['body'])
    file_name = body['fileName']

    # Delete from S3
    s3_client.delete_object(
        Bucket=os.environ['S3_BUCKET'],
        Key=file_name
    )

    # Delete metadata from DynamoDB
    table.delete_item(
        Key={
            'FileID': file_name
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps(f"File {file_name} deleted successfully")
    }


def update_file(event):
    body = json.loads(event['body'])
    file_content = b64decode(body['file'])
    file_name = body['fileName']
    file_type = body['fileType']

    # Update file in S3
    s3_client.put_object(
        Bucket=os.environ['S3_BUCKET'],
        Key=file_name,
        Body=file_content,
        ContentType=file_type
    )

    # Optionally update metadata in DynamoDB (e.g., update timestamp)
    table.update_item(
        Key={
            'FileID': file_name
        },
        UpdateExpression="SET #ts = :t",
        ExpressionAttributeNames={
            "#ts": "Timestamp"
        },
        ExpressionAttributeValues={
            ":t": str(datetime.utcnow())
        }
    )

    return {
        'statusCode': 200,
        'body': json.dumps(f"File {file_name} updated successfully")
    }
