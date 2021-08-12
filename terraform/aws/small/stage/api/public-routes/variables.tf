variable "api_id" {
  type        = string
  description = "The API ID"
}

variable "api_integration_id" {
  type        = string
  description = "The API integration ID"
}

variable "public_endpoints" {
  type = map(object({
    method = string
    path   = string
  }))
  description = "A collection of public endpoints"
  default     = {}
}
