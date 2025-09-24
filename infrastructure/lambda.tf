data "aws_iam_policy" "lambda_basic_execution" {
  name = "AWSLambdaBasicExecutionRole"
}

# Action group Lambda execution role
resource "aws_iam_role" "lambda_steve_api" {
  name = "FunctionExecutionRoleForLambda_steveAPI"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "${local.account_id}"
          }
        }
      }
    ]
  })
  managed_policy_arns = [data.aws_iam_policy.lambda_basic_execution.arn]
}

# Action group Lambda function
data "archive_file" "steve_api_zip" {
  type             = "zip"
  source_file      = "./../src/app.py"
  output_path      = "./../tmp/steve_api.zip"
  output_file_mode = "0666"
}

resource "aws_lambda_function" "steve_api" {
  function_name = "steveAPI"
  role          = aws_iam_role.lambda_steve_api.arn
  description   = "A Lambda function for the steve API action group"
  filename      = data.archive_file.steve_api_zip.output_path
  handler       = "app.lambda_handler"
  runtime       = "python3.11"
  # source_code_hash is required to detect changes to Lambda code/zip
  source_code_hash = data.archive_file.steve_api_zip.output_base64sha256
}

resource "aws_lambda_permission" "steve_api" {
  action         = "lambda:invokeFunction"
  function_name  = aws_lambda_function.steve_api.function_name
  principal      = "bedrock.amazonaws.com"
  source_account = local.account_id
  source_arn     = "arn:aws:bedrock:${local.region}:${local.account_id}:agent/*"
}
