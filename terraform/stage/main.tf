data "aws_s3_bucket" "fox-source-bucket" {
  bucket = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-source-code"
}

data "aws_iam_role" "fox-lambda-role" {
  name = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-lambda-role"
}

# API

resource "aws_apigatewayv2_api" "fox_api" {
  name          = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-${var.stage_name}-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_headers  = ["Content-Type", "Authorization", "Location"]
    expose_headers = ["Location"]
    allow_origins  = ["*"]
    allow_methods  = ["*"]
  }
  tags = {
    originator = "xilution.com"
  }
}

# Lambda Layer

resource "aws_lambda_layer_version" "fox_lambda_layer_version" {
  layer_name          = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-${var.stage_name}-lambda-layer"
  compatible_runtimes = [var.lambda_runtime]
  s3_bucket           = data.aws_s3_bucket.fox-source-bucket.id
  s3_key              = "${var.source_version}-layer.zip"
}

# Lambda

resource "aws_lambda_function" "fox_lambda_function" {
  function_name = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-${var.stage_name}-lambda"
  s3_bucket     = data.aws_s3_bucket.fox-source-bucket.id
  s3_key        = "${var.source_version}-function.zip"
  layers        = [aws_lambda_layer_version.fox_lambda_layer_version.arn]
  handler       = var.lambda_handler
  role          = data.aws_iam_role.fox-lambda-role.arn
  runtime       = var.lambda_runtime
  tags = {
    originator = "xilution.com"
  }
}

# Lambda Permissions

resource "aws_lambda_permission" "fox_lambda_permission" {
  function_name = aws_lambda_function.fox_lambda_function.function_name
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.client_aws_region}:${var.client_aws_account}:${aws_apigatewayv2_api.fox_api.id}/*/*"
}

# Integration

resource "aws_apigatewayv2_integration" "fox_api_integration" {
  api_id                 = aws_apigatewayv2_api.fox_api.id
  integration_type       = "AWS_PROXY"
  integration_method     = "POST"
  integration_uri        = "arn:aws:apigateway:${var.client_aws_region}:lambda:path/2015-03-31/functions/${aws_lambda_function.fox_lambda_function.arn}/invocations"
  connection_type        = "INTERNET"
  payload_format_version = "2.0"
}

# Stage

resource "aws_apigatewayv2_stage" "fox_api_stage" {
  api_id      = aws_apigatewayv2_api.fox_api.id
  name        = "$default"
  auto_deploy = true
  stage_variables = {
    stage = var.stage_name
  }
}

# Authorizer

resource "aws_apigatewayv2_authorizer" "authorizer" {
  count            = var.jwt_authorizer ? 1 : 0
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
  for_each  = toset(var.public_endpoints)
  api_id    = aws_apigatewayv2_api.fox_api.id
  route_key = "${upper(each.value.method)} ${each.value.path}"
  target    = "integrations/${aws_apigatewayv2_integration.fox_api_integration.id}"
}

# Private Routes

resource "aws_apigatewayv2_route" "private_api_route" {
  for_each             = toset(var.private_endpoints)
  api_id               = aws_apigatewayv2_api.fox_api.id
  route_key            = "${upper(each.value.method)} ${each.value.path}"
  target               = "integrations/${aws_apigatewayv2_integration.fox_api_integration.id}"
  authorization_scopes = each.value.scopes
  authorization_type   = "JWT"
  authorizer_id        = aws_apigatewayv2_authorizer.authorizer[count.index].id
}
