module "vpc" {
  source = "../../modules/vpc"
  stage = "dev"
  vpc_cidr = "10.0.0.0/16"
}

module "vpc_endpoint_s3" {
  source          = "../../modules/vpc_endpoint_s3"
  vpc_id          = module.vpc.vpc_id
  private_route_table_ids = module.vpc.private_route_table_ids
  allowed_bucket_arns = [module.s3.bucket_arn, "${module.s3.bucket_arn}/*"]
}

module "vpc_endpoint_lambda" {
  source                   = "../../modules/vpc_endpoint_lambda"
  vpc_id                   = module.vpc.vpc_id
  lambda_subnet_ids        = module.vpc.private_subnets
  lambda_security_group_ids = [module.vpc.aws_default_security_group_id]
}

module "s3" {
  source = "../../modules/s3"
  bucket_name        = "aws-vpc-lambda-integration-dev"
  enable_versioning  = false
}

data "archive_file" "lambda_layer_zip" {
  count = local.is_dummy_deploy ? 0 : 1
  type        = "zip"
  source_dir  = "${path.module}/dummy"
  output_path = "${path.module}/.terraform-artifacts/layer.zip"
  excludes = [
    "*.pyc",
    "__pycache__/**",
    "*.toml",
    "*.lock",
    ".venv/**",
  ]
}

data "archive_file" "lambda_zip" {
  count = local.is_dummy_deploy ? 0 : 1
  type        = "zip"
  source_dir  = "${path.module}/../../../src"
  output_path = "${path.module}/.terraform-artifacts/lambda.zip"
  excludes = [
    "*.pyc",
    "__pycache__/**",
    "*.toml",
    "*.lock",
    "layer/**",
    ".venv/**",
    "requirements.txt",
  ]
}

resource "aws_s3_object" "lambda_layer_archive" {
  count = local.is_dummy_deploy ? 0 : 1

  bucket = module.s3.bucket_id
  key    = "lambda-layers/dev-my-lambda-layer.zip"
  source = data.archive_file.lambda_layer_zip.output_path

  depends_on = [ 
    module.s3 
  ]
}

resource "aws_s3_object" "lambda_function_archive" {
  count = local.is_dummy_deploy ? 0 : 1

  bucket = module.s3.bucket_id
  key    = "lambda-functions/dev-my-lambda-fn.zip"
  source = data.archive_file.lambda_zip.output_path

  depends_on = [ 
    module.s3 
  ]
}

module "lambda_layer" {
  source             = "../../modules/lambda_layer"
  layer_name         = "dev-my-lambda-layer"
  runtime            = "python3.13"
  layer_source_path  = var.lambda_layer_zip_key
  s3_bucket_name     = module.s3.bucket_id
  depends_on = [ 
    aws_s3_object.lambda_layer_archive 
  ]
}

module "lambda" {
  source                    = "../../modules/lambda"
  function_name             = "dev-my-lambda-fn"
  handler                   = "lambda_function.lambda_handler"
  runtime                   = "python3.13"
  s3_bucket_name            = module.s3.bucket_id
  s3_key                    = var.lambda_zip_key
  layers                    = [module.lambda_layer.layer_arn]
  vpc_subnet_ids            = module.vpc.private_subnets
  vpc_security_group_id     = module.vpc.aws_default_security_group_id
  environment_variables     = {
    "BUCKET_NAME" = module.s3.bucket_id
  }
  depends_on = [ 
    module.vpc, 
    module.lambda_layer, 
    module.vpc_endpoint_lambda, 
    aws_s3_object.lambda_function_archive 
  ]
}