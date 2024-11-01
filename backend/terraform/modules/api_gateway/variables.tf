variable "lambda_function_arn" {
  description = "The ARN of the Lambda function."
  type        = string
}

variable "lambda_function_invoke_arn" {
  description = "The Invoke ARN of the Lambda function."
  type        = string
}

variable "lambda_function_name" {
  description = "The ARN of the Lambda function."
  type        = string
}

variable "stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
  default     = "dev_env"  # You can change the default value if needed
}

variable "region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}