# Root module outputs.tf

output "api_endpoint" {
  value = module.api_gateway.api_endpoint
}

output "bucket_name" {
  value = module.s3_bucket.bucket_name
}

# output "user_pool_id" {
#   description = "The ID of the Cognito User Pool"
#   value       = module.cognito.user_pool_id
# }
#
# output "user_pool_client_id" {
#   description = "The ID of the Cognito User Pool Client"
#   value       = module.cognito.user_pool_client_id
# }
#
# output "cognito_domain" {
#   value = module.cognito.cognito_domain
# }
#
# output "cognito_user_pool_arn" {
#   value = module.cognito.cognito_user_pool_arn
# }
