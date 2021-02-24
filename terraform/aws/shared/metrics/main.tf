data "aws_iam_role" "cloudwatch-events-rule-invocation-role" {
  name = "xilution-cloudwatch-events-rule-invocation-role"
}

data "aws_lambda_function" "metrics-reporter-lambda" {
  function_name = "xilution-client-metrics-reporter-lambda"
}

# Metrics

resource "aws_cloudwatch_event_rule" "every-ten-minute-event-rule" {
  name                = "xilution-fox-${substr(var.pipeline_id, 0, 8)}-cloudwatch-event-rule"
  schedule_expression = "rate(10 minutes)"
  role_arn            = data.aws_iam_role.cloudwatch-events-rule-invocation-role.arn
  tags = {
    originator = "xilution.com"
  }
}

resource "aws_lambda_permission" "allow-every-ten-minute-event-rule" {
  action        = "lambda:InvokeFunction"
  function_name = data.aws_lambda_function.metrics-reporter-lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every-ten-minute-event-rule.arn
}

output "every-ten-minute-event-rule" {
  value = aws_cloudwatch_event_rule.every-ten-minute-event-rule
}
