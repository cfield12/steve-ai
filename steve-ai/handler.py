import os
import boto3
import json
import logging


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)
logger.info("Starting the application")
logger.info("Environment variables: %s", os.environ)

# create a boto3 bedrock client
bedrock_agent_runtime_client = boto3.client(
    "bedrock-agent-runtime", region_name="eu-west-2"
)


def retrieveAndGenerate(question, kbId, model_arn, sessionId=None):
    if sessionId != "None":
        return bedrock_agent_runtime_client.retrieve_and_generate(
            input={"text": question},
            retrieveAndGenerateConfiguration={
                "type": "KNOWLEDGE_BASE",
                "knowledgeBaseConfiguration": {
                    "knowledgeBaseId": kbId,
                    "modelArn": model_arn,
                },
            },
            sessionId=sessionId,
        )
    else:
        return bedrock_agent_runtime_client.retrieve_and_generate(
            input={"text": question},
            retrieveAndGenerateConfiguration={
                "type": "KNOWLEDGE_BASE",
                "knowledgeBaseConfiguration": {
                    "knowledgeBaseId": kbId,
                    "modelArn": model_arn,
                },
            },
        )


def lambda_handler(event, context):
    # Extract the question and session ID from the event
    question = event["queryStringParameters"]["question"]

    # Verify AWS credentials
    sts_client = boto3.client("sts")
    response = sts_client.get_caller_identity()
    logger.info("AWS credentials: %s", response)

    try:
        session_id = event["queryStringParameters"]["session_id"]
    except:
        session_id = "None"

    # Assuming you've set the KNOWLEDGE_BASE_ID as an environment variable in your Lambda function
    kb_id = os.environ["KNOWLEDGE_BASE_ID"]

    # Specify the model ID and construct its ARN. Update these placeholders as needed.
    model_id = "anthropic.claude-v2"
    region = "eu-west-2"
    model_arn = f"arn:aws:bedrock:{region}::foundation-model/{model_id}"

    # Call the retrieve and generate function
    try:
        response = retrieveAndGenerate(question, kb_id, model_arn, session_id)
    except Exception as e:
        logger.error("Error retrieving and generating: %s", e)
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

    # Extract the generated text and session ID from the response
    generated_text = response["output"]["text"]
    session_id = response.get("sessionId", "")

    headers = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Credentials": True,
    }
    # Return the response in the expected format
    return {
        "statusCode": 200,
        "headers": headers,
        "body": json.dumps(
            {
                "question": question.strip(),
                "answer": generated_text.strip(),
                "sessionId": session_id,
            },
            ensure_ascii=False,
        ),
    }
