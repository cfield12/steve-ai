data "aws_bedrock_foundation_model" "kb" {
  model_id = var.model_id
}

resource "aws_iam_role_policy" "bedrock_kb_model" {
  name = "AmazonBedrockFoundationModelPolicyForKnowledgeBase_${var.application_name}"
  role = aws_iam_role.steve_iam_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "bedrock:InvokeModel"
        Effect   = "Allow"
        Resource = data.aws_bedrock_foundation_model.kb.model_arn
      }
    ]
  })
}

resource "aws_opensearchserverless_access_policy" "steve_kb" {
  name = var.kb_oss_collection_name
  type = "data"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index"
          Resource = [
            "index/${var.kb_oss_collection_name}/*"
          ]
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:UpdateIndex",
            "aoss:WriteDocument"
          ]
        },
        {
          ResourceType = "collection"
          Resource = [
            "collection/${var.kb_oss_collection_name}"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DescribeCollectionItems",
            "aoss:UpdateCollectionItems"
          ]
        }
      ],
      Principal = [
        aws_iam_role.steve_iam_role.arn,
        data.aws_caller_identity.this.arn
      ]
    }
  ])
}

resource "aws_opensearchserverless_security_policy" "steve_kb_encryption" {
  name = var.kb_oss_collection_name
  type = "encryption"
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${var.kb_oss_collection_name}"
        ]
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

resource "aws_opensearchserverless_security_policy" "steve_kb_network" {
  name = var.kb_oss_collection_name
  type = "network"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource = [
            "collection/${var.kb_oss_collection_name}"
          ]
        },
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/${var.kb_oss_collection_name}"
          ]
        }
      ]
      AllowFromPublic = true
    }
  ])
}

resource "aws_opensearchserverless_collection" "steve_kb" {
  name = var.kb_oss_collection_name
  type = "VECTORSEARCH"
  depends_on = [
    aws_opensearchserverless_access_policy.steve_kb,
    aws_opensearchserverless_security_policy.steve_kb_encryption,
    aws_opensearchserverless_security_policy.steve_kb_network
  ]
}

resource "aws_iam_role_policy" "bedrock_kb_steve_kb_oss" {
  name = "BedrockOSSPolicyForKnowledgeBase_${var.application_name}"
  role = aws_iam_role.steve_iam_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "aoss:APIAccessAll"
        Effect   = "Allow"
        Resource = aws_opensearchserverless_collection.steve_kb.arn
      }
    ]
  })
}


resource "opensearch_index" "steve_kb" {
  name                           = "bedrock-knowledge-base-default-index"
  number_of_shards               = "2"
  number_of_replicas             = "0"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings                       = <<-EOF
    {
      "properties": {
        "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": 1024,
          "method": {
            "name": "hnsw",
            "engine": "faiss",
            "parameters": {
              "m": 16,
              "ef_construction": 512
            },
            "space_type": "l2"
          }
        },
        "AMAZON_BEDROCK_METADATA": {
          "type": "text",
          "index": "false"
        },
        "AMAZON_BEDROCK_TEXT_CHUNK": {
          "type": "text",
          "index": "true"
        }
      }
    }
  EOF
  force_destroy                  = true
  depends_on                     = [aws_opensearchserverless_collection.steve_kb]
}

resource "time_sleep" "aws_iam_role_policy_bedrock_kb_steve_kb_oss" {
  create_duration = "60s"
  depends_on      = [aws_iam_role_policy.bedrock_kb_steve_kb_oss]
}

resource "aws_bedrockagent_knowledge_base" "steve_kb" {
  name     = var.application_name
  role_arn = aws_iam_role.steve_iam_role.arn
  knowledge_base_configuration {
    vector_knowledge_base_configuration {
      embedding_model_arn = data.aws_bedrock_foundation_model.kb.model_arn
    }
    type = "VECTOR"
  }
  storage_configuration {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration {
      collection_arn    = aws_opensearchserverless_collection.steve_kb.arn
      vector_index_name = "bedrock-knowledge-base-default-index"
      field_mapping {
        vector_field   = "bedrock-knowledge-base-default-vector"
        text_field     = "AMAZON_BEDROCK_TEXT_CHUNK"
        metadata_field = "AMAZON_BEDROCK_METADATA"
      }
    }
  }
  depends_on = [
    aws_iam_role_policy.bedrock_kb_model,
    aws_iam_role_policy.bedrock_kb_s3,
    opensearch_index.steve_kb,
    time_sleep.aws_iam_role_policy_bedrock_kb_steve_kb_oss
  ]
}

resource "aws_bedrockagent_data_source" "steve_kb" {
  knowledge_base_id = aws_bedrockagent_knowledge_base.steve_kb.id
  name              = "${var.application_name}DataSource"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = aws_s3_bucket.knowledgebase_steve.arn
    }
  }
}

resource "aws_bedrockagent_agent" "steve_asst" {
  agent_name              = "steveAssistant"
  agent_resource_role_arn = aws_iam_role.steve_iam_role.arn
  description             = "An assisant that provides aws cli/boto3 information"
  foundation_model        = data.aws_bedrock_foundation_model.this.model_id
  instruction             = "You are an assistant that looks up aws documentation information. A user may ask you what the aws-cli call is to assume role. They may not provide all details."
}

resource "aws_bedrockagent_agent_knowledge_base_association" "steve_kb" {
  agent_id             = aws_bedrockagent_agent.steve_asst.id
  description          = "Knowledge base for AWS CLI and boto3 documentation. Use this to look up AWS service information, CLI commands, and API references."
  knowledge_base_id    = aws_bedrockagent_knowledge_base.steve_kb.id
  knowledge_base_state = "ENABLED"
}