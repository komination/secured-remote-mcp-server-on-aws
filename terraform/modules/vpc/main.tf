data "aws_availability_zones" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "${var.stage}-vpc-tf"
  cidr = var.vpc_cidr

  azs = slice(data.aws_availability_zones.current.names, 0, 3)

  public_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 0),
    cidrsubnet(var.vpc_cidr, 8, 1),
    cidrsubnet(var.vpc_cidr, 8, 2)
  ]

  private_subnets = [
    cidrsubnet(var.vpc_cidr, 8, 3),
    cidrsubnet(var.vpc_cidr, 8, 4),
    cidrsubnet(var.vpc_cidr, 8, 5)
  ]

  create_igw = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = false

  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}