provider "aws" {
  assume_role {
    role_arn = "arn:aws:iam::${var.client_aws_account}:role/xilution-agent-role"
  }
  region  = "us-east-1"
}
