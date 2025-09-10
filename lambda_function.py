import boto3
from PIL import Image
import io
import os

s3 = boto3.client("s3")

def lambda_handler(event, context):
    # Get bucket and object key from the event
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    # Define destination bucket
    destination_bucket = os.environ['DEST_BUCKET']
    
    # Download the image from S3
    response = s3.get_object(Bucket=source_bucket, Key=object_key)
    image_data = response['Body'].read()
    
    # Open image using Pillow
    image = Image.open(io.BytesIO(image_data))
    
    # Resize (example: 200x200)
    image = image.resize((200, 200))
    
    # Save resized image to memory
    buffer = io.BytesIO()
    image.save(buffer, "JPEG")
    buffer.seek(0)
    
    # Upload resized image to destination bucket
    s3.put_object(
        Bucket=destination_bucket,
        Key=f"resized-{object_key}",
        Body=buffer,
        ContentType="image/jpeg"
    )
    
    return {
        "statusCode": 200,
        "body": f"Resized image uploaded to {destination_bucket}/resized-{object_key}"
    }
