resource "random_string" "username" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "random_password" "password" {
  length  = var.password_length
  upper   = var.password_upper
  lower   = var.password_lower
  numeric = var.password_number
  special = var.password_special
}

resource "aws_cognito_user_pool" "this" {
  name = "${var.name_prefix}-${random_string.username.result}"
}

resource "aws_cognito_user_pool_client" "this" {
  name                = var.client_name != "" ? var.client_name : "${var.name_prefix}-client"
  user_pool_id        = aws_cognito_user_pool.this.id
  generate_secret     = false
  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
}

resource "aws_cognito_user" "temp" {
  user_pool_id         = aws_cognito_user_pool.this.id
  username             = random_string.username.result
  force_alias_creation = false
  temporary_password   = random_password.password.result

  lifecycle {
    ignore_changes = [temporary_password]
  }
}

resource "aws_cognito_user_pool_domain" "domain" {
  count        = var.enable_domain ? 1 : 0
  domain       = var.domain_prefix != "" ? var.domain_prefix : "${var.name_prefix}-${random_string.username.result}"
  user_pool_id = aws_cognito_user_pool.this.id
}
