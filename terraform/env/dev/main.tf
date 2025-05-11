module "vpc" {
  source = "../../modules/vpc"
  stage = "dev"
  vpc_cidr = "10.0.0.0/16"
}

module "s3" {
  source = "../../modules/s3"
  bucket_name        = "aws-vpc-lambda-integration-dev"
  enable_versioning  = true
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

module "lambda_layer" {
  source             = "../../modules/lambda_layer"
  layer_name         = "dev-my-lambda-layer"
  runtime            = "python3.13"
  s3_bucket_name     = module.s3.bucket_id
  s3_key             = var.lambda_layer_zip_key
  depends_on = [ 
    module.s3
  ]
}

module "lambda" {
  source                    = "../../modules/lambda"
  function_name             = "dev-my-lambda-fn"
  handler                   = "lambda_function.lambda_handler"
  runtime                   = "python3.13"
  s3_bucket_name            = module.s3.bucket_id
  s3_key                    = var.lambda_zip_key
  s3_bucket_arn             = module.s3.bucket_arn
  layers                    = [module.lambda_layer.layer_arn]
  vpc_subnet_ids            = module.vpc.private_subnets
  vpc_security_group_id     = module.vpc.aws_default_security_group_id
  environment_variables     = {
    "BUCKET_NAME" = module.s3.bucket_id
  }
  depends_on = [
    module.lambda_layer
  ]
}