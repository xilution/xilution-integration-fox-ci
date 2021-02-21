data "aws_s3_bucket" "fox-source-bucket" {
  bucket = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-source-code"
}

data "aws_iam_role" "fox-lambda-role" {
  name = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-lambda-role"
}

locals {
  api_count = var.public_endpoints != null ? 1 : 0 + var.private_endpoints != null ? 1 : 0
}

# Lambda Layer

locals {
  layer_s3_key = "${var.source_version}-layer.zip"
}

resource "aws_lambda_layer_version" "fox_lambda_layer_version" {
  layer_name          = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-${var.stage_name}-lambda-layer"
  compatible_runtimes = [var.lambda_runtime]
  s3_bucket           = data.aws_s3_bucket.fox-source-bucket.id
  s3_key              = local.layer_s3_key
  source_code_hash    = filebase64sha256(local.layer_s3_key)
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
  environment {
    variables = {
      STAGE_NAME      = var.stage_name
      FOX_PIPELINE_ID = var.fox_pipeline_id
      PIPELINE_ID     = var.fox_pipeline_id
      NO_COLOR        = "true"
    }
  }
  tags = {
    originator = "xilution.com"
  }
}

module "fox_api" {
  count              = local.api_count
  source             = "./api"
  fox_pipeline_id    = var.fox_pipeline_id
  stage_name         = var.stage_name
  client_aws_account = var.client_aws_account
  client_aws_region  = var.client_aws_region
  aws_lambda_function = {
    function_name = aws_lambda_function.fox_lambda_function.id
    arn           = aws_lambda_function.fox_lambda_function.arn
  }
  public_endpoints  = var.public_endpoints
  private_endpoints = var.private_endpoints
  jwt_authorizer    = var.jwt_authorizer
}
