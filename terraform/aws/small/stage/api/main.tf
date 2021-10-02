locals {
  authorizer_count     = var.jwt_authorizer != null ? 1 : 0
  public_routes_count  = length(keys(coalesce(var.public_endpoints, {}))) > 0 ? 1 : 0
  private_routes_count = length(keys(coalesce(var.private_endpoints, {}))) > 0 ? 1 : 0
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

resource "aws_ssm_parameter" "aws_apigatewayv2_api_id" {
  name  = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-${lower(var.stage_name)}-aws-apigatewayv2-api-id"
  type  = "String"
  value = aws_apigatewayv2_api.fox_api.id
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

# Public Routes

module "public_api_route" {
  count              = local.public_routes_count
  source             = "./public-routes"
  api_id             = aws_apigatewayv2_api.fox_api.id
  api_integration_id = aws_apigatewayv2_integration.fox_api_integration.id
  public_endpoints   = var.public_endpoints
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

# Private Routes

module "private_api_route" {
  count              = local.private_routes_count
  source             = "./private-routes"
  api_id             = aws_apigatewayv2_api.fox_api.id
  api_integration_id = aws_apigatewayv2_integration.fox_api_integration.id
  private_endpoints  = var.private_endpoints
  authorizer_id      = aws_apigatewayv2_authorizer.authorizer[0].id
}

# Custom Domain

//module "custom_domain" {
//  count      = try(trimspace(var.domain), "") != "" ? 1 : 0
//  source     = "./custom-domain"
//  api_id     = aws_apigatewayv2_api.fox_api.id
//  domain     = var.domain
//  stage_name = var.stage_name
//}
