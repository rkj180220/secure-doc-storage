resource "aws_api_gateway_rest_api" "doc_api" {
  name        = "DocumentSharingAPI"
  description = "API for the secure document sharing system."
}

resource "aws_api_gateway_resource" "file" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  parent_id   = aws_api_gateway_rest_api.doc_api.root_resource_id
  path_part   = "file"
}

resource "aws_api_gateway_method" "upload_file" {
  rest_api_id   = aws_api_gateway_rest_api.doc_api.id
  resource_id   = aws_api_gateway_resource.file.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "upload_file_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.doc_api.id
  resource_id             = aws_api_gateway_resource.file.id
  http_method             = aws_api_gateway_method.upload_file.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_invoke_arn
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_api_gateway_deployment" "doc_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  # stage_name  = var.stage_name

  depends_on = [
    aws_api_gateway_integration.upload_file_lambda
  ]

  # triggers = {
  #   redeployment = sha1(jsonencode(aws_api_gateway_rest_api.doc_api.body))
  # }
  #
  # lifecycle {
  #   create_before_destroy = true
  # }
}

resource "aws_api_gateway_stage" "dev_stage" {
  rest_api_id   = aws_api_gateway_rest_api.doc_api.id
  stage_name    = var.stage_name
  deployment_id = aws_api_gateway_deployment.doc_api_deployment.id

  lifecycle {
    ignore_changes = [
      deployment_id,
    ]
  }
}

resource "aws_api_gateway_method_settings" "doc_api_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.doc_api.id
  stage_name  = aws_api_gateway_stage.dev_stage.stage_name
  method_path = "${aws_api_gateway_resource.file.path_part}/${aws_api_gateway_method.upload_file.http_method}"

  settings {
    data_trace_enabled = true
    logging_level      = "INFO"
    metrics_enabled    = true
  }
}

output "api_endpoint" {
  value = "https://${aws_api_gateway_rest_api.doc_api.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.dev_stage.stage_name}/file"
}