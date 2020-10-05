resource "aws_s3_bucket" "static_content_bucket" {
  bucket = "xilution-fox-${substr(var.fox_pipeline_id, 0, 8)}-${lower(var.stage_name)}-web-content"
  acl    = "public-read"
  tags = {
    xilution_organization_id = var.organization_id
    originator               = "xilution.com"
  }
}
