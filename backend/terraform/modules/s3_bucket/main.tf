resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "secure_document_storage" {
  bucket = "secure-doc-storage-${random_id.bucket_id.hex}"
}

resource "aws_s3_bucket_versioning" "secure_document_storage_versioning" {
  bucket = aws_s3_bucket.secure_document_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure_document_storage_encryption" {
  bucket = aws_s3_bucket.secure_document_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Default S3 encryption (AES-256)
    }
  }
}



resource "aws_s3_bucket_policy" "secure_document_storage" {
  bucket = aws_s3_bucket.secure_document_storage.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid = "AllowAPIGatewayAccess",
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.secure_document_storage.arn}/*"
      },
      {
        Sid = "AllowLambdaAccess",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.secure_document_storage.arn}/*"
      }
    ]
  })
}

output "bucket_name" {
  value = aws_s3_bucket.secure_document_storage.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.secure_document_storage.arn
}
