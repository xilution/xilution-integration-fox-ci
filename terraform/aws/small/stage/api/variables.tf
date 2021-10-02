variable "fox_pipeline_id" {
  type        = string
  description = "The Fox Pipeline ID"
}

variable "stage_name" {
  type        = string
  description = "The Stage Name"
}

variable "client_aws_account" {
  type        = string
  description = "The Xilution Client AWS Account ID"
}

variable "client_aws_region" {
  type        = string
  description = "The Xilution Client AWS Region"
}

variable "aws_lambda_function" {
  type = object({
    function_name = string
    arn           = string
  })
  description = "Lambda Function Details"
}

variable "public_endpoints" {
  type = map(object({
    method = string
    path   = string
  }))
  description = "A collection of public endpoints"
  default     = {}
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

variable "jwt_authorizer" {
  type = object({
    audience = list(string)
    issuer   = string
  })
  description = "The JWT Authorizer"
  default     = null
}

variable "domain" {
  type        = string
  description = "The API Domain"
}
