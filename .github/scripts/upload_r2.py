import boto3
from botocore.client import Config
import os

# R2 credentials from environment variables
ACCESS_KEY_ID = os.getenv("R2_ACCESS_KEY_ID")
SECRET_ACCESS_KEY = os.getenv("R2_SECRET_ACCESS_KEY")
ACCOUNT_ID = os.getenv("R2_ACCOUNT_ID")
BUCKET_NAME = os.getenv("R2_BUCKET_NAME")
ENDPOINT_URL = f"https://6a6842b1f08007f455a005a0b47656c2.r2.cloudflarestorage.com"

# File details
FILE_PATH = os.getenv("FILE_PATH", "file.bin")
OBJECT_KEY = os.getenv("OBJECT_KEY", "file.bin")

s3_client = boto3.client(
    's3',
    endpoint_url=ENDPOINT_URL,
    aws_access_key_id=ACCESS_KEY_ID,
    aws_secret_access_key=SECRET_ACCESS_KEY,
    config=Config(signature_version='s3v4'),
    region_name='auto'
)

def upload_large_file(file_path, bucket, key):
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"File {file_path} not found")
    
    mpu = s3_client.create_multipart_upload(Bucket=bucket, Key=key)
    upload_id = mpu['UploadId']
    
    parts = []
    part_size = 5 * 1024 * 1024
    file_size = os.path.getsize(file_path)
    
    print(f"Starting multipart upload for {key} (Upload ID: {upload_id})")

    with open(file_path, 'rb') as f:
        part_number = 1
        while True:
            data = f.read(part_size)
            if not data:
                break
                
            print(f"Uploading part {part_number}...")
            response = s3_client.upload_part(
                Bucket=bucket,
                Key=key,
                PartNumber=part_number,
                UploadId=upload_id,
                Body=data
            )
            parts.append({
                'PartNumber': part_number,
                'ETag': response['ETag']
            })
            part_number += 1
    
    print("Completing multipart upload...")
    s3_client.complete_multipart_upload(
        Bucket=bucket,
        Key=key,
        UploadId=upload_id,
        MultipartUpload={'Parts': parts}
    )
    print(f"File {key} uploaded successfully to {bucket}")

if __name__ == "__main__":
    try:
        upload_large_file(FILE_PATH, BUCKET_NAME, OBJECT_KEY)
    except Exception as e:
        print(f"Error uploading file: {e}")
        s3_client.abort_multipart_upload(Bucket=BUCKET_NAME, Key=OBJECT_KEY, UploadId=upload_id)
        exit(1)