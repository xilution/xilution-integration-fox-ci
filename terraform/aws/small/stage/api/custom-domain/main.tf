# Locals

locals {
  prodCount = var.stage_name == "prod" ? 1 : 0
}

# Route 53 Zone

data "aws_ssm_parameter" "route53_zone_id" {
  name = "${var.domain}_route53-hosted-zone-name"
}

data "aws_route53_zone" "route53_zone" {
  name = data.aws_ssm_parameter.route53_zone_id.value
}

# API Custom Domain Certificate and Validation

resource "aws_acm_certificate" "certificate" {
  domain_name               = "${var.stage_name}.${var.domain}"
  subject_alternative_names = compact([var.stage_name == "prod" ? var.domain : null])
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name       = "${var.stage_name}.${var.domain}"
    originator = "xilution.com"
  }
}

resource "aws_route53_record" "cert-validation-records" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.route53_zone.zone_id
}

resource "aws_acm_certificate_validation" "cert-validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-validation-records : record.fqdn]
}

# API Custom Custom Domain

resource "aws_apigatewayv2_domain_name" "domain" {
  count       = local.prodCount
  domain_name = var.domain

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.certificate.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_domain_name" "domain_stage" {
  domain_name = "${lower(var.stage_name)}.${var.domain}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.certificate.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

# API Custom Mapping

resource "aws_apigatewayv2_api_mapping" "mapping" {
  count       = local.prodCount
  api_id      = var.api_id
  domain_name = aws_apigatewayv2_domain_name.domain[count.index].id
  stage       = "$default"
}

resource "aws_apigatewayv2_api_mapping" "mapping_stage" {
  api_id      = var.api_id
  domain_name = aws_apigatewayv2_domain_name.domain_stage.id
  stage       = "$default"
}

# API Custom Domain Route 53 Records

resource "aws_route53_record" "route53_record" {
  count   = local.prodCount
  name    = aws_apigatewayv2_domain_name.domain[count.index].domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.route53_zone.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain[count.index].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain[count.index].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "route53_record_stage" {
  name    = aws_apigatewayv2_domain_name.domain_stage.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.route53_zone.zone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.domain_stage.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.domain_stage.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

