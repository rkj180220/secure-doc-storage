resource "random_id" "cognito_id" {
  byte_length = 8
}

resource "aws_cognito_user_pool" "user_pool" {
  name = "doc-sharing-users-${random_id.cognito_id.hex}"

  admin_create_user_config {
    allow_admin_create_user_only = true  # Only admins can create users
    invite_message_template {
      email_message = "Hello {username}, your temporary password is {####}. Please sign in using this email."
      email_subject = "Welcome to the Document Sharing System"
      sms_message = "Hello {username}, your temporary password is {####}. Please sign in using this email."
    }
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name               = "doc-sharing-client"
  user_pool_id      = aws_cognito_user_pool.user_pool.id
  generate_secret    = false
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

resource "aws_cognito_user_pool_domain" "user_pool_domain" {
  domain      = "doc-sharing-app-domain-${random_id.cognito_id.hex}"  # Change this to your desired domain name
  user_pool_id = aws_cognito_user_pool.user_pool.id
}

output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.user_pool_client.id
}

output "cognito_domain" {
  value = aws_cognito_user_pool_domain.user_pool_domain.domain
}

output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool.user_pool.arn
}
