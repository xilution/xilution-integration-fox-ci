# Public Routes

resource "aws_apigatewayv2_route" "public_api_route" {
  for_each  = var.public_endpoints
  api_id    = var.api_id
  route_key = "${upper(each.value.method)} ${each.value.path}"
  target    = "integrations/${var.api_integration_id}"
}
