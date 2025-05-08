module "lambda_layer_s3" {
  source = "terraform-aws-modules/lambda/aws"
  version = "7.20.2"

  create_layer = true

  layer_name          = var.layer_name
  compatible_runtimes = [var.runtime]

  source_path = var.layer_source_path

  store_on_s3 = true
  s3_bucket   = var.s3_bucket_name
}