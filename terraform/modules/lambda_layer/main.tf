module "lambda_layer_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.2"

  create_layer   = true
  create_package = false

  layer_name          = var.layer_name
  compatible_runtimes = [var.runtime]

  s3_existing_package = {
    bucket = var.s3_bucket_name
    key    = var.s3_key
  }

  ignore_source_code_hash = true
}