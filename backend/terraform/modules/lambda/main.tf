resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_policy"
  role   = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        Resource = "${var.s3_bucket_arn}/*",
        Effect   = "Allow"
      },
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query"
        ],
        Resource = "${var.dynamodb_table_arn}",
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_lambda_function" "file_operations" {
  function_name = "FileOperations"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "file_operations.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      S3_BUCKET     = var.s3_bucket
      DYNAMODB_TABLE = var.dynamodb_table
    }
  }

  # The ZIP file containing the Lambda code
  filename         = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")
}

output "function_name" {
  value = aws_lambda_function.file_operations.function_name
}

# modules/lambda/outputs.tf
output "lambda_function_arn" {
  value = aws_lambda_function.file_operations.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.file_operations.invoke_arn
}
