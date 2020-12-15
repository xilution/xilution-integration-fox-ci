variable "client_aws_account" {
  type        = string
  description = "The Xilution Client AWS Account ID"
}

variable "api_id" {
  type = string
  description = "The API ID"
}

variable "route_keys" {
  type = list(string)
  description = "A List of Route Keys"
}

variable "target" {
  type = string
  description = "The Route Target"
}
