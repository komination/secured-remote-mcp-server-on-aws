terraform {
  required_version = ">=1.12.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.72.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7.0"
    }
  }
}
