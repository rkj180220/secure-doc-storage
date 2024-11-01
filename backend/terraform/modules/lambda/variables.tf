variable "s3_bucket" {
  description = "The S3 bucket to store files."
  type        = string
}

variable "s3_bucket_arn" {
  description = "The S3 bucket arn to store files."
  type        = string
}

variable "dynamodb_table" {
  description = "The DynamoDB table for metadata."
  type        = string
}

variable "dynamodb_table_arn" {
  description = "The DynamoDB table for metadata."
  type        = string
}
