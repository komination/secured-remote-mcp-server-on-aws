module "vpc" {
  source   = "../../modules/vpc"
  stage    = "prod"
  vpc_cidr = "10.1.0.0/16"
}

module "s3" {
  source            = "../../modules/s3"
  bucket_name       = "prod-aws-vpc-lambda-integration"
  enable_versioning = true
}

module "vpc_endpoint_s3" {
  source                  = "../../modules/vpc_endpoint_s3"
  vpc_id                  = module.vpc.vpc_id
  private_route_table_ids = module.vpc.private_route_table_ids
  allowed_bucket_arns     = [module.s3.bucket_arn, "${module.s3.bucket_arn}/*"]
}

module "vpc_endpoint_lambda" {
  source                    = "../../modules/vpc_endpoint_lambda"
  vpc_id                    = module.vpc.vpc_id
  lambda_subnet_ids         = module.vpc.private_subnets
  lambda_security_group_ids = [module.vpc.aws_default_security_group_id]
}

module "lambda_layer" {
  source         = "../../modules/lambda_layer"
  layer_name     = "prod-secured-remote-mcp-server-on-aws-layer"
  runtime        = "python3.13"
  s3_bucket_name = local.has_artifacts_bucket ? var.existing_artifacts_bucket_name : module.s3.bucket_id
  s3_key         = var.lambda_layer_zip_key
  depends_on = [
    module.s3
  ]
}

module "lambda" {
  source                = "../../modules/lambda"
  function_name         = "prod-secured-remote-mcp-server-on-aws-lambda"
  handler               = "run.sh"
  runtime               = "python3.13"
  s3_bucket_name        = local.has_artifacts_bucket ? var.existing_artifacts_bucket_name : module.s3.bucket_id
  s3_key                = var.lambda_zip_key
  s3_bucket_arn         = module.s3.bucket_arn
  layers                = [module.lambda_layer.layer_arn]
  vpc_subnet_ids        = module.vpc.private_subnets
  vpc_security_group_id = module.vpc.aws_default_security_group_id

  # Production-specific performance settings
  memory_size                    = 512 # Increased from default 256MB for better performance
  timeout                        = 120 # Increased from default 60s for complex operations
  reserved_concurrent_executions = 10  # Ensure consistent availability

  environment_variables = {
    "BUCKET_NAME" = module.s3.bucket_id
  }
  depends_on = [
    module.lambda_layer
  ]
}

module "cognito" {
  source      = "../../modules/cognito"
  name_prefix = "prod-kjawu1aw21aga"
}

module "api_gateway" {
  source              = "../../modules/api_gateway"
  name                = "prod-secured-remote-mcp-server-on-aws-api"
  description         = "Production environment API"
  lambda_function_arn = module.lambda.function_arn
  cors_configuration = {
    allow_headers = ["*"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }
  cognito_user_pool_id        = module.cognito.user_pool_id
  cognito_user_pool_client_id = module.cognito.user_pool_client_id
  cognito_scope_read          = module.cognito.scope_read

  # Production-specific throttling settings
  throttle_burst_limit = 1000 # Higher burst limit for production
  throttle_rate_limit  = 500  # Higher rate limit for production
}