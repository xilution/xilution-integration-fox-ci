resource "aws_apigatewayv2_route" "unsecure_api_route" {
  count     = var.endpoint.authorization ? 0 : 1
  api_id    = var.api_id
  route_key = "${upper(var.endpoint.method)} ${var.endpoint.path}"
  target    = var.target
}

resource "aws_apigatewayv2_route" "secure_api_route" {
  count                = var.endpoint.authorization ? 1 : 0
  api_id               = var.api_id
  route_key            = "${upper(var.endpoint.method)} ${var.endpoint.path}"
  target               = var.target
  authorization_scopes = var.endpoint.authorization.scopes
  authorization_type   = "JWT"
  authorizer_id        = var.authorizer_id
}
