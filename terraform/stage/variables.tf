variable "organization_id" {
  type        = string
  description = "The Xilution Account Organization ID or Xilution Account Sub-Organization ID"
}

variable "product_id" {
  type        = string
  description = "The Product ID"
  default     = "444f956231be4028bc370c03f433d340"
}

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

variable "xilution_pipeline_type" {
  type        = string
  description = "The Pipeline Type"
}
