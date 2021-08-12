variable "authorizer_id" {
  type        = string
  description = "The Authorizer ID"
}

variable "api_id" {
  type        = string
  description = "The API ID"
}

variable "api_integration_id" {
  type        = string
  description = "The API integration ID"
}

variable "private_endpoints" {
  type = map(object({
    method = string
    path   = string
    scopes = list(string)
  }))
  description = "A collection of private endpoints"
  default     = {}
}
