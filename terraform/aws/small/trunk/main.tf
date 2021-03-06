data "aws_iam_role" "cloudwatch-events-rule-invocation-role" {
  name = "xilution-cloudwatch-events-rule-invocation-role"
}

data "aws_lambda_function" "metrics-reporter-lambda" {
  function_name = "xilution-client-metrics-reporter-lambda"
}

# Source Bucket

module "source-bucket" {
  source      = "../../shared/source-bucket"
  pipeline_id = var.fox_pipeline_id
}

# Lambda Role

resource "aws_iam_role" "fox-lambda-role" {
  name               = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-lambda-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["lambda.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
  tags = {
    originator = "xilution.com"
  }
}

resource "aws_iam_policy_attachment" "fox-lambda-role-basic-execution-policy" {
  name       = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-lambda-role-basic-execution-policy"
  roles      = [aws_iam_role.fox-lambda-role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "fox-lambda-role-dynamo-access" {
  name       = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-lambda-role-dynamo-access"
  roles      = [aws_iam_role.fox-lambda-role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_policy_attachment" "fox-lambda-role-vpc-access" {
  name       = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-lambda-role-vpc-access"
  roles      = [aws_iam_role.fox-lambda-role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Metrics

module "metrics" {
  source      = "../../shared/metrics"
  pipeline_id = var.fox_pipeline_id
}

resource "aws_cloudwatch_event_target" "cloudwatch-event-target" {
  rule  = module.metrics.every-ten-minute-event-rule.name
  arn   = data.aws_lambda_function.metrics-reporter-lambda.arn
  input = <<-DOC
  {
    "Environment": "prod",
    "OrganizationId": "${var.organization_id}",
    "ProductId": "${var.product_id}",
    "Duration": 600000,
    "MetricDataQueries": [
      {
        "Id": "client_metrics_reporter_lambda_duration",
        "MetricStat": {
          "Metric": {
            "Namespace": "AWS/Lambda",
            "MetricName": "Duration",
            "Dimensions": [
              {
                "Name": "FunctionName",
                "Value": "xilution-client-metrics-reporter-lambda"
              }
            ]
          },
          "Period": 60,
          "Stat": "Average",
          "Unit": "Milliseconds"
        }
      }
    ],
    "MetricNameMaps": [
      {
        "Id": "client_metrics_reporter_lambda_duration",
        "MetricName": "client-metrics-reporter-lambda-duration"
      }
    ]
  }
  DOC
}

# Dashboards

resource "aws_cloudwatch_dashboard" "fox-cloudwatch-dashboard" {
  dashboard_name = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-dashboard"

  dashboard_body = <<-EOF
  {
    "widgets": [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              "i-012345"
            ]
          ],
          "period": 300,
          "stat": "Average",
          "region": "us-east-1",
          "title": "EC2 Instance CPU"
        }
      },
      {
        "type": "text",
        "x": 0,
        "y": 7,
        "width": 3,
        "height": 3,
        "properties": {
          "markdown": "Hello world"
        }
      }
    ]
  }
  EOF
}
