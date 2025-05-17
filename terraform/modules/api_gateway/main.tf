data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

module "api_gateway" {
  source                = "terraform-aws-modules/apigateway-v2/aws"
  version               = "5.3.0"
  name                  = var.name
  description           = var.description
  protocol_type         = "HTTP"
  cors_configuration    = var.cors_configuration
  create_domain_name    = false
  create_domain_records = false

  authorizers = var.enable_cognito_auth ? {
    cognito = {
      name             = "${var.name}-cognito"
      authorizer_type  = "JWT"
      identity_sources = ["$request.header.Authorization"]
      jwt_configuration = {
        audience = [var.cognito_user_pool_client_id]
        issuer   = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${var.cognito_user_pool_id}"
      }
    }
  } : {}

  routes = {
    "$default" = {
      authorization_type = var.enable_cognito_auth ? "JWT" : "NONE"
      authorizer_key     = var.enable_cognito_auth ? "cognito" : null

      integration = {
        uri = var.lambda_function_arn
      }
    }
  }
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "${var.name}-invoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${module.api_gateway.api_execution_arn}/*"
}
