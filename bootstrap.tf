terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe",
      version = "~> 0.65.2"
    }
  }
  backend "local" {}
}

variable "github_owner_name" {
  description = "The owner of the GitHub repository"
  type        = string
}
variable "repo_name" {
  description = "The name of the GitHub repository"
  type        = string
}

provider "tfe" {}

data "tfe_github_app_installation" "my" {
  name = var.github_owner_name
}

resource "tfe_project" "platform" {
  name = var.repo_name
}

resource "tfe_workspace" "dev" {
  name       = "dev-${var.repo_name}"
  project_id = tfe_project.platform.id



  vcs_repo {
    identifier                 = "${var.github_owner_name}/${var.repo_name}"
    branch                     = "develop"
    github_app_installation_id = data.tfe_github_app_installation.my.id
  }
}

resource "tfe_workspace" "prod" {
  name       = "prod-${var.repo_name}"
  project_id = tfe_project.platform.id

  vcs_repo {
    identifier                 = "${var.github_owner_name}/${var.repo_name}"
    branch                     = "main"
    github_app_installation_id = data.tfe_github_app_installation.my.id
  }
}