output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.knowledgebase_steve.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.knowledgebase_steve.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.knowledgebase_steve.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.knowledgebase_steve.bucket_regional_domain_name
}

output "dataset_folder_key" {
  description = "Key of the dataset folder"
  value       = aws_s3_object.dataset_folder.key
}

output "output_folder_key" {
  description = "Key of the output folder"
  value       = aws_s3_object.output_folder.key
}

output "knowledge_base_id" {
  description = "ID of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.steve_kb.id
}

output "knowledge_base_arn" {
  description = "ARN of the Bedrock Knowledge Base"
  value       = aws_bedrockagent_knowledge_base.steve_kb.arn
}

# Export Knowledge Base ID to a file for Serverless to read
output "export_serverless_config" {
  description = "Export configuration for Serverless Framework"
  value = {
    knowledge_base_id = aws_bedrockagent_knowledge_base.steve_kb.id
    s3_bucket_name    = aws_s3_bucket.knowledgebase_steve.bucket
  }
}
