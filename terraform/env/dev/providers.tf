provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Project     = "aws-vpc-lambda-integration"
    }
  }
}