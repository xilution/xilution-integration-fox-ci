locals {
  authorizer_count = var.jwt_authorizer != null ? 1 : 0
}

# API

resource "aws_apigatewayv2_api" "fox_api" {
  name          = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-${var.stage_name}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers  = ["*"]
    expose_headers = ["*"]
    allow_origins  = ["*"]
    allow_methods  = ["*"]
    max_age        = 300
  }
  tags = {
    originator = "xilution.com"
  }
}

# Lambda Permissions

resource "aws_lambda_permission" "fox_lambda_permission" {
  function_name = var.aws_lambda_function.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.client_aws_region}:${var.client_aws_account}:${aws_apigatewayv2_api.fox_api.id}/*/*"
}

# Integration

resource "aws_apigatewayv2_integration" "fox_api_integration" {
  api_id                 = aws_apigatewayv2_api.fox_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = "arn:aws:apigateway:${var.client_aws_region}:lambda:path/2015-03-31/functions/${var.aws_lambda_function.arn}/invocations"
  connection_type        = "INTERNET"
  payload_format_version = "2.0"
}

# Stage

resource "aws_apigatewayv2_stage" "fox_api_stage" {
  api_id      = aws_apigatewayv2_api.fox_api.id
  name        = "$default"
  auto_deploy = true
  stage_variables = {
    stageName  = var.stage_name
    pipelineId = var.fox_pipeline_id
  }
}

# Authorizer

resource "aws_apigatewayv2_authorizer" "authorizer" {
  count            = local.authorizer_count
  api_id           = aws_apigatewayv2_api.fox_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-${var.stage_name}-authorizer"

  jwt_configuration {
    audience = var.jwt_authorizer.audience
    issuer   = var.jwt_authorizer.issuer
  }
}

# Public Routes

resource "aws_apigatewayv2_route" "public_api_route" {
  for_each  = var.public_endpoints
  api_id    = aws_apigatewayv2_api.fox_api.id
  route_key = "${upper(each.value.method)} ${each.value.path}"
  target    = "integrations/${aws_apigatewayv2_integration.fox_api_integration.id}"
}

# Private Routes

resource "aws_apigatewayv2_route" "private_api_route" {
  for_each             = var.private_endpoints
  api_id               = aws_apigatewayv2_api.fox_api.id
  route_key            = "${upper(each.value.method)} ${each.value.path}"
  target               = "integrations/${aws_apigatewayv2_integration.fox_api_integration.id}"
  authorization_scopes = each.value.scopes
  authorization_type   = "JWT"
  authorizer_id        = aws_apigatewayv2_authorizer.authorizer[0].id
}
