module "vpc" {
  source = "../../modules/vpc"
  stage = "dev"
  vpc_cidr = "10.0.0.0/16"
  enable_nat_gateway = false
  one_nat_gateway_per_az = false
}

// S3用 VPCエンドポイント
module "vpc_endpoint_s3" {
  source          = "../../modules/vpc_endpoint_s3"
  vpc_id          = module.vpc.vpc_id
  route_table_ids = module.vpc.private_subnets
}

// デフォルトセキュリティグループを取得
resource "aws_default_security_group" "default" {
  vpc_id = module.vpc.vpc_id
}

// Lambda用 VPCエンドポイント
module "vpc_endpoint_lambda" {
  source                   = "../../modules/vpc_endpoint_lambda"
  vpc_id                   = module.vpc.vpc_id
  lambda_subnet_ids        = module.vpc.private_subnets
  lambda_security_group_ids = [aws_default_security_group.default.id]
}