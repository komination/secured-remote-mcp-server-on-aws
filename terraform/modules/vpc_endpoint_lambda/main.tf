data "aws_vpc_endpoint_service" "lambda" {
  service      = "lambda"
  service_type = "Interface"
}

resource "aws_vpc_endpoint" "lambda" {
  vpc_id              = var.vpc_id
  service_name        = data.aws_vpc_endpoint_service.lambda.service_name
  vpc_endpoint_type   = data.aws_vpc_endpoint_service.lambda.service_type
  subnet_ids          = var.lambda_subnet_ids
  security_group_ids  = var.lambda_security_group_ids
  private_dns_enabled = true
}