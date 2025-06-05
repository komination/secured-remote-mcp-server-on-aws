# =============================================================================
# Terraform Configuration and Providers
# =============================================================================

terraform {
  required_version = ">=1.12.1"

  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.65.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.72.1"
    }
  }
  # 暫定的にローカル使用
  backend "local" {}
}

provider "tfe" {}

provider "aws" {
  region = "ap-northeast-1"
}

# =============================================================================
# Variables
# =============================================================================

variable "github_owner_name" {
  description = "The owner of the GitHub repository"
  type        = string
}

variable "repo_name" {
  description = "The name of the GitHub repository"
  type        = string
}

# =============================================================================
# Data Sources
# =============================================================================

# 現在のorganization情報を取得
data "tfe_organization" "current" {}

# 現在のAWSアカウント情報を取得
data "aws_caller_identity" "current" {}

# GitHub App インストール情報を取得
data "tfe_github_app_installation" "my" {
  name = var.github_owner_name
}

# Terraform Cloud の OIDC 証明書を動的に取得
data "tls_certificate" "hcp_terraform" {
  url = "https://app.terraform.io/.well-known/openid-configuration"
}

# GitHub Actions の OIDC 証明書を動的に取得
data "tls_certificate" "github_actions" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# 既存の HCP Terraform OIDC プロバイダーを確認
data "aws_iam_openid_connect_provider" "existing_hcp_terraform" {
  for_each = toset([
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/app.terraform.io"
  ])
  arn = each.value
}

# 既存の GitHub Actions OIDC プロバイダーを確認
data "aws_iam_openid_connect_provider" "existing_github_actions" {
  for_each = toset([
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
  ])
  arn = each.value
}

# =============================================================================
# Local Values
# =============================================================================

locals {
  # OIDC Provider Existence Checks
  hcp_terraform_oidc_provider_exists  = length(data.aws_iam_openid_connect_provider.existing_hcp_terraform) > 0
  github_actions_oidc_provider_exists = length(data.aws_iam_openid_connect_provider.existing_github_actions) > 0

  # OIDC Provider ARNs
  hcp_terraform_oidc_provider_arn  = local.hcp_terraform_oidc_provider_exists ? values(data.aws_iam_openid_connect_provider.existing_hcp_terraform)[0].arn : aws_iam_openid_connect_provider.hcp_terraform[0].arn
  github_actions_oidc_provider_arn = local.github_actions_oidc_provider_exists ? values(data.aws_iam_openid_connect_provider.existing_github_actions)[0].arn : aws_iam_openid_connect_provider.github_actions[0].arn

  # GitHub Repository Configuration
  allowed_github_repositories = [var.repo_name]
  full_paths                  = [for repo in local.allowed_github_repositories : "repo:${var.github_owner_name}/${repo}:*"]
}

# =============================================================================
# AWS OIDC Identity Providers
# =============================================================================

resource "aws_iam_openid_connect_provider" "hcp_terraform" {
  count           = local.hcp_terraform_oidc_provider_exists ? 0 : 1
  url             = "https://app.terraform.io"
  client_id_list  = ["aws.workload.identity"]
  thumbprint_list = [data.tls_certificate.hcp_terraform.certificates[0].sha1_fingerprint]
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count           = local.github_actions_oidc_provider_exists ? 0 : 1
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

# =============================================================================
# AWS IAM Roles and Policies
# =============================================================================

resource "aws_iam_role" "hcp_terraform_role" {
  name = "hcp-terraform-role-${var.repo_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity",
        Effect    = "Allow",
        Principal = { Federated = local.hcp_terraform_oidc_provider_arn },
        Condition = {
          StringEquals = { "app.terraform.io:aud" = "aws.workload.identity" },
          StringLike = {
            "app.terraform.io:sub" = [
              "organization:${data.tfe_organization.current.name}:project:*:workspace:${tfe_workspace.dev.name}:run_phase:*",
              "organization:${data.tfe_organization.current.name}:project:*:workspace:${tfe_workspace.prod.name}:run_phase:*"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-${var.repo_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Federated = local.github_actions_oidc_provider_arn },
        Action    = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_owner_name}/${var.repo_name}:environment:develop",
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# HCP Terraform用最小権限ポリシー
resource "aws_iam_policy" "hcp_terraform_policy" {
  name        = "hcp-terraform-policy-${var.repo_name}"
  description = "Minimal permissions for HCP Terraform to manage MCP infrastructure"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CoreInfrastructureServices"
        Effect = "Allow"
        Action = [
          "sts:GetCallerIdentity",
          "sts:AssumeRole",
          "apigateway:*",
          "lambda:*",
          "s3:*",
          "ec2:*",
          "cognito-idp:*",
          "secretsmanager:*",
          "logs:*"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMReadOperations"
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMWriteOperationsForLambda"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:TagRole",
          "iam:UntagRole"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "hcp_terraform_policy" {
  role       = aws_iam_role.hcp_terraform_role.name
  policy_arn = aws_iam_policy.hcp_terraform_policy.arn
}

# GitHub Actions用最小権限ポリシー
resource "aws_iam_policy" "github_actions_policy" {
  name        = "github-actions-policy-${var.repo_name}"
  description = "Minimal permissions for GitHub Actions CI/CD pipeline"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ArtifactManagement"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::*${var.repo_name}*/lambda/*",
          "arn:aws:s3:::*${var.repo_name}*/lambda-layers/*",
          "arn:aws:s3:::*artifacts*/lambda/*",
          "arn:aws:s3:::*artifacts*/lambda-layers/*"
        ]
        Condition = {
          StringEquals = {
            "s3:ExistingObjectTag/Environment" = "develop"
          }
        }
      },
      {
        Sid    = "S3ArtifactManagementFallback"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject"
        ]
        Resource = [
          "arn:aws:s3:::*${var.repo_name}*/lambda/*",
          "arn:aws:s3:::*${var.repo_name}*/lambda-layers/*",
          "arn:aws:s3:::*artifacts*/lambda/*",
          "arn:aws:s3:::*artifacts*/lambda-layers/*"
        ]
      },
      {
        Sid    = "LambdaLayerManagement"
        Effect = "Allow"
        Action = [
          "lambda:PublishLayerVersion"
        ]
        Resource = [
          "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:layer:*${var.repo_name}*"
        ]
      },
      {
        Sid    = "LambdaFunctionUpdate"
        Effect = "Allow"
        Action = [
          "lambda:UpdateFunctionConfiguration",
          "lambda:UpdateFunctionCode"
        ]
        Resource = [
          "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:*${var.repo_name}*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

# =============================================================================
# Terraform Cloud Project and Workspaces
# =============================================================================

resource "tfe_project" "platform" {
  name = var.repo_name
}

resource "tfe_workspace" "dev" {
  name              = "dev-${var.repo_name}"
  project_id        = tfe_project.platform.id
  working_directory = "terraform/env/dev"

  vcs_repo {
    identifier                 = "${var.github_owner_name}/${var.repo_name}"
    branch                     = "develop"
    github_app_installation_id = data.tfe_github_app_installation.my.id
  }
}

resource "tfe_workspace" "prod" {
  name              = "prod-${var.repo_name}"
  project_id        = tfe_project.platform.id
  working_directory = "terraform/env/prod"

  vcs_repo {
    identifier                 = "${var.github_owner_name}/${var.repo_name}"
    branch                     = "main"
    github_app_installation_id = data.tfe_github_app_installation.my.id
  }
}

# =============================================================================
# Terraform Cloud Workspace Settings
# =============================================================================

resource "tfe_workspace_settings" "dev" {
  workspace_id   = tfe_workspace.dev.id
  execution_mode = "remote"
}

resource "tfe_workspace_settings" "prod" {
  workspace_id   = tfe_workspace.prod.id
  execution_mode = "remote"
}

# =============================================================================
# Terraform Cloud Workspace Variables
# =============================================================================

# Dev Environment Variables
resource "tfe_variable" "dev_aws_provider_auth" {
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = tfe_workspace.dev.id
  description  = "Enable AWS provider authentication via OIDC"
}

resource "tfe_variable" "dev_aws_run_role_arn" {
  key          = "TFC_AWS_RUN_ROLE_ARN"
  value        = aws_iam_role.hcp_terraform_role.arn
  category     = "env"
  workspace_id = tfe_workspace.dev.id
  description  = "AWS IAM Role ARN for OIDC authentication"
}

# Prod Environment Variables
resource "tfe_variable" "prod_aws_provider_auth" {
  key          = "TFC_AWS_PROVIDER_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = tfe_workspace.prod.id
  description  = "Enable AWS provider authentication via OIDC"
}

resource "tfe_variable" "prod_aws_run_role_arn" {
  key          = "TFC_AWS_RUN_ROLE_ARN"
  value        = aws_iam_role.hcp_terraform_role.arn
  category     = "env"
  workspace_id = tfe_workspace.prod.id
  description  = "AWS IAM Role ARN for OIDC authentication"
}

# =============================================================================
# Outputs
# =============================================================================

# OIDC Provider Status and ARNs
output "hcp_terraform_oidc_provider_status" {
  value = local.hcp_terraform_oidc_provider_exists ? "Using existing OIDC provider" : "Created new OIDC provider"
}

output "hcp_terraform_oidc_provider_arn" {
  value       = local.hcp_terraform_oidc_provider_arn
  description = "ARN of the Terraform Cloud OIDC provider"
}

output "github_actions_oidc_provider_status" {
  value = local.github_actions_oidc_provider_exists ? "Using existing GitHub Actions OIDC provider" : "Created new GitHub Actions OIDC provider"
}

output "github_actions_oidc_provider_arn" {
  value       = local.github_actions_oidc_provider_arn
  description = "ARN of the GitHub Actions OIDC provider"
}

# IAM Role ARNs
output "hcp_terraform_iam_role_arn" {
  value       = aws_iam_role.hcp_terraform_role.arn
  description = "ARN of the IAM role for Terraform Cloud"
}

output "github_actions_iam_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "ARN of the IAM role for GitHub Actions"
}

# Workspace IDs
output "dev_workspace_id" {
  value       = tfe_workspace.dev.id
  description = "ID of the dev workspace"
}

output "prod_workspace_id" {
  value       = tfe_workspace.prod.id
  description = "ID of the prod workspace"
}

# IAM Policy ARNs
output "hcp_terraform_policy_arn" {
  value       = aws_iam_policy.hcp_terraform_policy.arn
  description = "ARN of the HCP Terraform minimal permissions policy"
}

output "github_actions_policy_arn" {
  value       = aws_iam_policy.github_actions_policy.arn
  description = "ARN of the GitHub Actions minimal permissions policy"
}
