Simple Guide: Serverless API using Lambda + API Gateway + CloudWatch Logs
This explains what you did in very simple steps so it’s easy to understand and revise later.

1. What We Built
We created a serverless API.
Flow:
Postman Web
     │
     ▼
API Gateway (receives request)
     │
     ▼
Lambda Function (runs code)
     │
     ▼
CloudWatch Logs (stores logs)

So when a user sends a request:
Request goes to API Gateway
API Gateway triggers Lambda
Lambda runs the code
Lambda logs data to CloudWatch
Response is sent back to user

2. Step 1 — Create Lambda Function
Go to:
AWS Console → Lambda → Create Function

Configuration used:
Function Name : serverless-api
Runtime       : Python 3.12
Execution Role: Create new role with basic Lambda permissions

Important thing created automatically:
AWSLambdaBasicExecutionRole

This role allows Lambda to write logs to CloudWatch.

3. Step 2 — Add Lambda Code
We added code that:
Reads the request body
Extracts the name
Sends a response
Logs request and response
Example logic:
Receive request
↓
Read body
↓
Get name
↓
Return message "Hello <name>"
↓
Log request to CloudWatch


4. Step 3 — Create API Gateway Trigger
Inside Lambda:
Add Trigger → API Gateway

Configuration used:
API Type        : HTTP API
Security        : Open
Deployment Stage: default

What AWS created automatically:
API Gateway
Route
Public endpoint

Example endpoint:
https://abc123.execute-api.us-east-1.amazonaws.com/default/serverless-api

This is the URL used to call the API.

5. Step 4 — Enable CORS
Because we used Postman Web (browser), we had to enable CORS.
Go to:
API Gateway → Your API → CORS

Configuration:
Access-Control-Allow-Origin  : *
Access-Control-Allow-Methods : GET, POST, OPTIONS
Access-Control-Allow-Headers : *

Then save and redeploy the API.
Why needed:
Browsers block requests without CORS permission


6. Step 5 — Test Using Postman Web
In Postman:
Method : POST

URL:
https://abc123.execute-api.us-east-1.amazonaws.com/default/serverless-api

Body → raw → JSON
{
  "name": "Bhavesh"
}

Response received:
{
 "message": "Hello Bhavesh"
}


7. Step 6 — View Logs in CloudWatch
Go to:
CloudWatch → Logs → Log Groups

Open:
/aws/lambda/serverless-api

Logs show:
START RequestId
Incoming request data
Response sent
END RequestId
Execution time

Example:
Incoming request:
{
 "method": "POST",
 "body": "{\"name\":\"Bhavesh\"}"
}

Response sent:
{
 "message": "Hello Bhavesh"
}


8. Important Configurations Used
Lambda
Runtime: Python
Role   : AWSLambdaBasicExecutionRole

Purpose:
Allows Lambda to write logs to CloudWatch


API Gateway
API Type : HTTP API
Security : Open
Stage    : default

Purpose:
Expose Lambda as public API


CORS
Allow-Origin  : *
Allow-Methods : GET, POST, OPTIONS

Purpose:
Allow browser/Postman Web requests


9. Problems We Faced
Error: Failed to fetch
Cause:
CORS not enabled

Fix:
Enable CORS in API Gateway


Internal Server Error
Cause:
Lambda couldn't read body

Fix:
Use event.get("body","{}")


10. Final Result
You successfully created a serverless API that:
Accepts HTTP requests
Runs Lambda function
Returns response
Logs requests in CloudWatch

Architecture:
Client (Postman)
      │
      ▼
API Gateway
      │
      ▼
Lambda
      │
      ▼
CloudWatch Logs


Key Learning
Lambda = compute
API Gateway = HTTP entry point
CloudWatch = logs and monitoring
Together they create a serverless backend API.

