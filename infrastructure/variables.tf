variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-2"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "knowledgebase-steve"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "application_name" {
  description = "Name of application"
  type        = string
  default     = "steve" 
}

variable "model_id" {
  description = "The ID of the foundational model used by the knowledge base."
  type        = string
  default     = "amazon.titan-embed-text-v2:0"
}

variable "kb_oss_collection_name" {
  description = "The name of the OSS collection for the knowledge base."
  type        = string
  default     = "bedrock-knowledge-base-steve-kb"
}
