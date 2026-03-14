
import json
import logging


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def lambda_handler(event, context):


    # log the entire request
    logger.info("Incoming request:")
    logger.info(json.dumps(event))


    body = json.loads(event.get("body", "{}"))
    name = body.get("name", "guest")


    response = {
        "message": f"Hello {name}"
    }


    logger.info("Response sent:")
    logger.info(json.dumps(response))


    return {
        "statusCode": 200,
        "body": json.dumps(response)
    }
