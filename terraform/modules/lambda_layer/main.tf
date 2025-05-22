module "lambda_layer_s3" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.20.2"

  create_layer   = true
  create_package = false

  layer_name               = var.layer_name
  compatible_runtimes      = ["python3.13"]
  compatible_architectures = ["x86_64"]

  s3_existing_package = {
    bucket = var.s3_bucket_name
    key    = var.s3_key
  }
}