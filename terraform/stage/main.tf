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

data "aws_vpc" "gazelle_vpc" {
  tags = {
    Name = "xilution-gazelle-${substr(var.gazelle_pipeline_id, 0, 8)}-vpc"
  }
}

data "aws_subnet" "gazelle_public_subnet_1" {
  tags = {
    Name = "xilution-gazelle-${substr(var.gazelle_pipeline_id, 0, 8)}-public-subnet-1"
  }
}

data "aws_subnet" "gazelle_public_subnet_2" {
  tags = {
    Name = "xilution-gazelle-${substr(var.gazelle_pipeline_id, 0, 8)}-public-subnet-2"
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

# Security Group

resource "aws_security_group" "lambda_security_group" {
  vpc_id = data.aws_vpc.gazelle_vpc.id
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
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
    security_group_ids = [
      aws_security_group.lambda_security_group.id
    ]
    subnet_ids = [
      data.aws_subnet.gazelle_public_subnet_1.id,
      data.aws_subnet.gazelle_public_subnet_2.id
    ]
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
