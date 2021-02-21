data "aws_s3_bucket" "fox-source-bucket" {
  bucket = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-source-code"
}

data "aws_s3_bucket_object" "fox-source-bucket-layer-source-zip" {
  bucket = data.aws_s3_bucket.fox-source-bucket.id
  key    = "${var.source_version}-layer.zip"
}

data "aws_s3_bucket_object" "fox-source-bucket-layer-source-sha256" {
  bucket = data.aws_s3_bucket.fox-source-bucket.id
  key    = "${var.source_version}-layer.zip.sha256"
}

data "aws_s3_bucket_object" "fox-source-bucket-function-source-zip" {
  bucket = data.aws_s3_bucket.fox-source-bucket.id
  key    = "${var.source_version}-function.zip"
}

data "aws_s3_bucket_object" "fox-source-bucket-function-source-sha256" {
  bucket = data.aws_s3_bucket.fox-source-bucket.id
  key    = "${var.source_version}-function.zip.sha256"
}

data "aws_iam_role" "fox-lambda-role" {
  name = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-lambda-role"
}

data "aws_security_groups" "lambda_security_groups" {
  tags = {
    vpc_tag = var.vpc_tag_value
  }
}

data "aws_vpc" "lambda_vpc" {
  tags = {
    vpc_tag = var.vpc_tag_value
  }
}

data "aws_subnet_ids" "lambda_subnet_ids" {
  vpc_id = data.aws_vpc.lambda_vpc.id
  tags = {
    vpc_tag = var.vpc_tag_value
  }
}

locals {
  api_count = var.public_endpoints != null ? 1 : 0 + var.private_endpoints != null ? 1 : 0
}

# Lambda Layer

resource "aws_lambda_layer_version" "fox_lambda_layer_version" {
  layer_name          = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-${var.stage_name}-lambda-layer"
  compatible_runtimes = [var.lambda_runtime]
  s3_bucket           = data.aws_s3_bucket.fox-source-bucket.id
  s3_key              = data.aws_s3_bucket_object.fox-source-bucket-layer-source-zip.key
  source_code_hash    = data.aws_s3_bucket_object.fox-source-bucket-layer-source-sha256.body
}

# Lambda

resource "aws_lambda_function" "fox_lambda_function" {
  function_name    = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-${var.stage_name}-lambda"
  s3_bucket        = data.aws_s3_bucket.fox-source-bucket.id
  s3_key           = data.aws_s3_bucket_object.fox-source-bucket-function-source-zip.key
  source_code_hash = data.aws_s3_bucket_object.fox-source-bucket-function-source-sha256.body
  layers           = [aws_lambda_layer_version.fox_lambda_layer_version.arn]
  handler          = var.lambda_handler
  role             = data.aws_iam_role.fox-lambda-role.arn
  runtime          = var.lambda_runtime
  timeout          = 30
  vpc_config {
    security_group_ids = data.aws_security_groups.lambda_security_groups.ids
    subnet_ids         = data.aws_subnet_ids.lambda_subnet_ids.ids
  }
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
