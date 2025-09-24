# AI Agent Knowledge Base - Infrastructure

This project contains the complete infrastructure for an AI Agent Knowledge Base system, including:

- **Terraform Configuration** - AWS infrastructure provisioning
- **Serverless Framework** - Lambda API deployment
- **S3 Storage** - Knowledge base data and Lambda layers

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   API Gateway   │───▶│  Lambda Function │───▶│  Bedrock Agent  │
│   (Serverless)  │    │   (Python 3.11)  │    │ Knowledge Base  │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                                ▼
                       ┌──────────────────┐
                       │   OpenSearch     │
                       │   Serverless     │
                       └──────────────────┘
```

## Components

### 1. Terraform Infrastructure
- S3 bucket for knowledge base data and Lambda layers
- Bedrock Agent Knowledge Base
- OpenSearch Serverless collection
- IAM roles and policies
- Lambda function (alternative to Serverless)

### 2. Serverless Framework API
- RESTful API endpoint for querying the knowledge base
- Lambda function with Bedrock integration
- CORS-enabled for web applications

## Prerequisites

- Terraform >= 1.0
- Node.js >= 18.0.0 (for Serverless Framework)
- AWS CLI configured with appropriate credentials
- AWS account with S3, Bedrock, and OpenSearch permissions
- Serverless Framework CLI

## Usage

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Review the plan:**
   ```bash
   terraform plan
   ```

3. **Apply the configuration:**
   ```bash
   terraform apply
   ```

4. **Optional - Use custom variables:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred values
   terraform apply
   ```

## Serverless Framework API

The Serverless Framework provides a RESTful API for querying the knowledge base. This is located in the `steve-ai/` directory.

### Setup

1. **Install Serverless Framework:**
   ```bash
   npm install -g serverless
   ```

2. **Navigate to the Serverless directory:**
   ```bash
   cd steve-ai/
   ```

3. **Install dependencies:**
   ```bash
   npm install
   ```

### Configuration

The `serverless.yml` file contains the configuration:

```yaml
service: knowledge-base-api
provider:
  name: aws
  runtime: python3.11
  stage: dev
  region: eu-west-2
  environment:
    KNOWLEDGE_BASE_ID: XXXXXXXXX  # Your Bedrock Knowledge Base ID
```

### Deployment

1. **Deploy the API:**
   ```bash
   serverless deploy
   ```

2. **Deploy to specific stage:**
   ```bash
   serverless deploy --stage production
   ```

3. **Deploy with verbose output:**
   ```bash
   serverless deploy --verbose
   ```

### API Usage

After deployment, you'll get an endpoint like:
```
https://xxxxxxxxxx.execute-api.eu-west-2.amazonaws.com/dev/
```

#### Query Parameters

- `question` (required) - Your question for the knowledge base
- `session_id` (optional) - Session ID for conversation context

#### Example API Calls

**Basic question:**
```bash
curl "https://xxxxxxxxxx.execute-api.eu-west-2.amazonaws.com/dev/?question=What%20is%20AWS%20Lambda?&session_id=None"
```

**With session context:**
```bash
curl "https://xxxxxxxxxx.execute-api.eu-west-2.amazonaws.com/dev/?question=How%20do%20I%20create%20a%20DynamoDB%20table?&session_id=my-session-123"
```

**Pretty-printed response:**
```bash
curl -s "https://xxxxxxxxxx.execute-api.eu-west-2.amazonaws.com/dev/?question=Explain%20AWS%20IAM%20roles&session_id=test-123" | jq .
```

#### Response Format

```json
{
  "question": "What is AWS Lambda?",
  "answer": "AWS Lambda is a serverless compute service...",
  "sessionId": "session-id-or-empty"
}
```

### Local Development

1. **Invoke function locally:**
   ```bash
   serverless invoke local --function invokeKnowledgeBase
   ```

2. **Install serverless-offline for local API:**
   ```bash
   serverless plugin install -n serverless-offline
   serverless offline
   ```

3. **Test with local endpoint:**
   ```bash
   curl "http://localhost:3000/dev/?question=Test%20question&session_id=local-test"
   ```

### Monitoring and Logs

1. **View function logs:**
   ```bash
   serverless logs --function invokeKnowledgeBase
   ```

2. **Tail logs in real-time:**
   ```bash
   serverless logs --function invokeKnowledgeBase --tail
   ```

3. **View CloudWatch logs:**
   ```bash
   aws logs describe-log-groups --log-group-name-prefix "/aws/lambda/knowledge-base-api"
   ```

### Management Commands

1. **Remove deployment:**
   ```bash
   serverless remove
   ```

2. **Get service info:**
   ```bash
   serverless info
   ```

3. **List functions:**
   ```bash
   serverless invoke list
   ```

4. **Check deployment status:**
   ```bash
   serverless deploy list
   ```

## Resources Created

### Terraform Resources
- S3 bucket: `knowledgebase-steve`
- Bedrock Agent Knowledge Base
- OpenSearch Serverless collection
- IAM roles and policies
- Lambda function (alternative to Serverless)

### Serverless Resources
- API Gateway endpoint
- Lambda function with Bedrock integration
- CloudWatch log groups
- IAM execution role

## Troubleshooting

### Common Issues

1. **Node.js Version Error:**
   ```bash
   # Error: Unsupported engine for serverless
   # Solution: Update Node.js to >= 18.0.0
   nvm install 18
   nvm use 18
   ```

2. **Permission Denied Errors:**
   ```bash
   # Ensure AWS credentials are configured
   aws configure list
   aws sts get-caller-identity
   ```

3. **Knowledge Base Not Found:**
   ```bash
   # Verify the Knowledge Base ID in serverless.yml
   aws bedrock-agent list-knowledge-bases
   ```

4. **CORS Issues:**
   - The API has CORS enabled for all origins
   - Check browser console for specific CORS errors

5. **Lambda Timeout:**
   - Default timeout is 60 seconds
   - Increase in serverless.yml if needed:
   ```yaml
   functions:
     invokeKnowledgeBase:
       timeout: 120
   ```

### Debugging

1. **Check Lambda logs:**
   ```bash
   serverless logs --function invokeKnowledgeBase --tail
   ```

2. **Test locally:**
   ```bash
   serverless invoke local --function invokeKnowledgeBase --data '{"queryStringParameters":{"question":"test","session_id":"test"}}'
   ```

3. **Verify API Gateway:**
   ```bash
   curl -v "https://your-api-id.execute-api.eu-west-2.amazonaws.com/dev/?question=test&session_id=test"
   ```

## Security Features

- Versioning enabled for data protection
- Server-side encryption for data at rest
- Public access blocked to prevent unauthorized access
- Proper IAM roles with minimal required permissions
- CORS configuration for web applications
- Proper tagging for resource management

## Outputs

After applying Terraform, you'll see:
- Bucket ID and ARN
- Bedrock Knowledge Base ID
- OpenSearch Collection endpoint
- Lambda function ARN (if using Terraform Lambda)

After deploying Serverless, you'll see:
- API Gateway endpoint URL
- Lambda function name and ARN
- CloudWatch log group names
