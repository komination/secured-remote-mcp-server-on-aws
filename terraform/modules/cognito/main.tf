data "aws_region" "current" {}

resource "aws_cognito_user_pool" "this" {
  name = "${var.name_prefix}-pool"
}

resource "aws_cognito_resource_server" "api" {
  user_pool_id = aws_cognito_user_pool.this.id
  identifier   = "api://${var.name_prefix}"
  name         = "${var.name_prefix}-rs"

  scope {
    scope_name        = "read"
    scope_description = "Read access to ${var.name_prefix}"
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name         = "${var.name_prefix}-machine"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = ["${aws_cognito_resource_server.api.identifier}/read"]
  supported_identity_providers         = ["COGNITO"]
  enable_token_revocation              = true

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.name_prefix}-auth"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_secretsmanager_secret" "client_secret" {
  name        = "${var.name_prefix}-cognito-client-secret"
  description = "Cognito client credentials for machine-to-machine"
}

resource "aws_secretsmanager_secret_version" "client_secret" {
  secret_id = aws_secretsmanager_secret.client_secret.id
  secret_string = jsonencode({
    client_id     = aws_cognito_user_pool_client.this.id
    client_secret = aws_cognito_user_pool_client.this.client_secret
    domain        = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
    scope         = "${aws_cognito_resource_server.api.identifier}/read"
  })
}
