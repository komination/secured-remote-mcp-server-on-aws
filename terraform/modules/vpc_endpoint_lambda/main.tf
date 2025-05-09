// デフォルトリージョンを取得

data "aws_region" "current" {
}

resource "aws_vpc_endpoint" "lambda" {
  vpc_id               = var.vpc_id
  service_name         = "com.amazonaws.${data.aws_region.current.name}.lambda"
  vpc_endpoint_type    = "Interface"
  subnet_ids           = var.lambda_subnet_ids
  security_group_ids   = var.lambda_security_group_ids
  private_dns_enabled  = true
}