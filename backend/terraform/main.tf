module "s3_bucket" {
  source = "./modules/s3_bucket"
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "lambda" {
  source = "./modules/lambda"
  s3_bucket = module.s3_bucket.bucket_name
  s3_bucket_arn = module.s3_bucket.bucket_arn
  dynamodb_table = module.dynamodb.table_name
  dynamodb_table_arn = module.dynamodb.table_arn
}

module "api_gateway" {
  source               = "./modules/api_gateway"
  lambda_function_arn  = module.lambda.lambda_function_arn  # Pass the function ARN
  lambda_function_name  = module.lambda.function_name  # Pass the function name
  lambda_function_invoke_arn = module.lambda.lambda_invoke_arn
}

# module "cognito" {
#   source = "./modules/cognito"
# }
