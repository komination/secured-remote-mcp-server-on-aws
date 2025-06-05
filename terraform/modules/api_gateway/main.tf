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

  stage_default_route_settings = {
    throttling_burst_limit = var.throttle_burst_limit
    throttling_rate_limit  = var.throttle_rate_limit
  }

  authorizers = {
    cognito = {
      name             = "${var.name}-cognito"
      authorizer_type  = "JWT"
      identity_sources = ["$request.header.Authorization"]
      jwt_configuration = {
        audience = [var.cognito_user_pool_client_id]
        issuer   = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${var.cognito_user_pool_id}"
      }
    }
  }

  routes = {
    "$default" = {
      authorization_type   = "JWT"
      authorizer_key       = "cognito"
      authorization_scopes = [var.cognito_scope_read]

      integration = {
        uri = var.lambda_function_arn
      }
      method = "ANY"
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
