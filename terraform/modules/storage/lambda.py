import json
import logging
import urllib.parse

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):
    for record in event.get("Records", []):
        bucket = record["s3"]["bucket"]["name"]
        key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])

        logger.info("Image received: %s", key)

        print(json.dumps({
            "message": "Image received",
            "bucket": bucket,
            "filename": key
        }))

    return {
        "statusCode": 200,
        "body": "Asset processed successfully"
    }
