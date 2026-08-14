############################################
# DynamoDB Table
############################################

resource "aws_dynamodb_table" "items" {
  name         = "Items"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "customerId"
    type = "S"
  }

  global_secondary_index {
    name = "idx_global_customerId"

    key_schema {
      attribute_name = "customerId"
      key_type       = "HASH"
    }

    key_schema {
      attribute_name = "id"
      key_type       = "RANGE"
    }

    projection_type = "ALL"
  }

  tags = {
    Name        = "project-bedrock-items"
    Environment = "production"
  }
}
