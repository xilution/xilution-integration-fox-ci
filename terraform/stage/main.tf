resource "aws_apigatewayv2_route" "api_route" {
  for_each  = toset(var.route_keys)
  api_id    = var.api_id
  route_key = each.value
  target    = var.target
}
