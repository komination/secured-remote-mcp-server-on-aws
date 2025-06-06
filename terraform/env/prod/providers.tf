provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "prod"
      Project     = "aws-vpc-lambda-integration"
    }
  }
}