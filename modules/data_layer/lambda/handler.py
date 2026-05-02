import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    This function wakes up every time a file lands in the S3 raw bucket.
    Right now it just logs the event — in a real platform you'd
    kick off a Glue job, validate the file, or call an API here.
    """

    for record in event["Records"]:
        bucket = record["s3"]["bucket"]["name"]
        key    = record["s3"]["object"]["key"]
        size   = record["s3"]["object"]["size"]

        logger.info(f"New file received!")
        logger.info(f"  Bucket : {bucket}")
        logger.info(f"  File   : {key}")
        logger.info(f"  Size   : {size} bytes")

    return {
        "statusCode": 200,
        "body": json.dumps("File ingestion logged successfully")
    }
