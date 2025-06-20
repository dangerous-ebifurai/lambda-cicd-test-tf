# DynamoDB Table for testing
resource "aws_dynamodb_table" "test_table" {
  name           = "${var.pj_name}-test-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  range_key      = "sort_key"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "sort_key"
    type = "S"
  }

  # Global Secondary Index for testing queries
  global_secondary_index {
    name     = "status-index"
    hash_key = "status"

    projection_type = "ALL"
  }

  attribute {
    name = "status"
    type = "S"
  }

  tags = {
    Name        = "${var.pj_name}-test-table"
    Environment = "test"
    Project     = var.pj_name
  }
}

# Test items for the DynamoDB table
resource "aws_dynamodb_table_item" "test_item_1" {
  table_name = aws_dynamodb_table.test_table.name
  hash_key   = aws_dynamodb_table.test_table.hash_key
  range_key  = aws_dynamodb_table.test_table.range_key

  item = jsonencode({
    id = {
      S = "test-001"
    }
    sort_key = {
      S = "user#001"
    }
    name = {
      S = "Test User 1"
    }
    email = {
      S = "test1@example.com"
    }
    status = {
      S = "active"
    }
    created_at = {
      S = "2024-01-01T00:00:00Z"
    }
    age = {
      N = "25"
    }
  })
}

resource "aws_dynamodb_table_item" "test_item_2" {
  table_name = aws_dynamodb_table.test_table.name
  hash_key   = aws_dynamodb_table.test_table.hash_key
  range_key  = aws_dynamodb_table.test_table.range_key

  item = jsonencode({
    id = {
      S = "test-002"
    }
    sort_key = {
      S = "user#002"
    }
    name = {
      S = "Test User 2"
    }
    email = {
      S = "test2@example.com"
    }
    status = {
      S = "inactive"
    }
    created_at = {
      S = "2024-01-02T00:00:00Z"
    }
    age = {
      N = "30"
    }
  })
}

resource "aws_dynamodb_table_item" "test_item_3" {
  table_name = aws_dynamodb_table.test_table.name
  hash_key   = aws_dynamodb_table.test_table.hash_key
  range_key  = aws_dynamodb_table.test_table.range_key

  item = jsonencode({
    id = {
      S = "test-003"
    }
    sort_key = {
      S = "product#001"
    }
    name = {
      S = "Test Product"
    }
    description = {
      S = "This is a test product for demonstration"
    }
    status = {
      S = "active"
    }
    price = {
      N = "99.99"
    }
    category = {
      S = "electronics"
    }
  })
}

# Output the table name and ARN for reference
output "dynamodb_table_name" {
  description = "Name of the DynamoDB test table"
  value       = aws_dynamodb_table.test_table.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB test table"
  value       = aws_dynamodb_table.test_table.arn
}
