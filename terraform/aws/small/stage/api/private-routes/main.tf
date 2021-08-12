# Private Routes

resource "aws_apigatewayv2_route" "private_api_route" {
  for_each             = var.private_endpoints
  api_id               = var.api_id
  route_key            = "${upper(each.value.method)} ${each.value.path}"
  target               = "integrations/${var.api_integration_id}"
  authorization_scopes = each.value.scopes
  authorization_type   = "JWT"
  authorizer_id        = var.authorizer_id
}
