variable "organization_id" {
  type        = string
  description = "The Xilution Account Organization ID or Xilution Account Sub-Organization ID"
}

variable "product_id" {
  type        = string
  description = "The Product ID"
  default     = "9ead02f5d8a0420aaa5668e863055168"
}

variable "gazelle_pipeline_id" {
  type        = string
  description = "The Gazelle Pipeline ID"
}

variable "fox_pipeline_id" {
  type        = string
  description = "The Fox Pipeline ID"
}

variable "client_aws_account" {
  type        = string
  description = "The Xilution Client AWS Account ID"
}

variable "client_aws_region" {
  type        = string
  description = "The Xilution Client AWS Region"
}

variable "xilution_aws_account" {
  type        = string
  description = "The Xilution AWS Account ID"
}

variable "xilution_aws_region" {
  type        = string
  description = "The Xilution AWS Region"
}

variable "xilution_environment" {
  type        = string
  description = "The Xilution Environment"
}

variable "pipeline_type" {
  type        = string
  description = "The Pipeline Type"
}
