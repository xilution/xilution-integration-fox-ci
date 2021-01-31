variable "apiId" {
  type        = string
  description = "The API ID"
}

variable "target" {
  type        = string
  description = "The API Route Target"
}

variable "endpoint" {
  type = object({
    id     = string,
    method = string,
    path   = string,
    authorization = object({
      scopes = list(string)
    })
  })
  description = "The API Settings"
}

variable "authorizerId" {
  type        = string
  description = "The Authorizer Name"
}
