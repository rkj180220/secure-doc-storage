resource "aws_dynamodb_table" "file_metadata" {
  name           = "FileMetadata"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "FileID"
  range_key      = "UserID"

  attribute {
    name = "FileID"
    type = "S"
  }

  attribute {
    name = "UserID"
    type = "S"
  }

  tags = {
    Name = "File Metadata Table"
  }
}

output "table_name" {
  value = aws_dynamodb_table.file_metadata.name
}

output "table_arn" {
  value = aws_dynamodb_table.file_metadata.arn
}