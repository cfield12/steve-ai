# S3 bucket for AI agent knowledge base
resource "aws_s3_bucket" "knowledgebase_steve" {
  bucket = "knowledgebase-steve-ai"

  tags = {
    Name        = "Knowledge Base Steve"
    Purpose     = "AI Agent Storage"
    Environment = "production"
  }
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "knowledgebase_steve_versioning" {
  bucket = aws_s3_bucket.knowledgebase_steve.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "knowledgebase_steve_encryption" {
  bucket = aws_s3_bucket.knowledgebase_steve.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "knowledgebase_steve_pab" {
  bucket = aws_s3_bucket.knowledgebase_steve.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Create dataset folder
resource "aws_s3_object" "dataset_folder" {
  bucket = aws_s3_bucket.knowledgebase_steve.id
  key    = "dataset/"

  # This creates a folder by uploading an empty object
  content = ""
}

# Create output folder
resource "aws_s3_object" "output_folder" {
  bucket = aws_s3_bucket.knowledgebase_steve.id
  key    = "output/"

  # This creates a folder by uploading an empty object
  content = ""
}

# Create lambdalayer folder
resource "aws_s3_object" "lambdalayer_prefix" {
  bucket  = aws_s3_bucket.knowledgebase_steve.id
  key     = "lambdalayer/"
  content = ""
}
