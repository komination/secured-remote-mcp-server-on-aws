terraform {
  backend "s3" {}
  # backend "s3" {
  #   bucket = "shared-tfstate-dev"
  #   key    = "vpc-lambda-integration/dev.tfstate"
  #   region = "ap-northeast-1"
  # }
}
