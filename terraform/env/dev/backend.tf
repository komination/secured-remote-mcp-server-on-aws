terraform {
  cloud {
    organization = "komine_terraform_study"
    workspaces {
      name = "aws-vpc-lambda-integration"
    }
  }
}
