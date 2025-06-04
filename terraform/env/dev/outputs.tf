output "lambda_function_name" {
  description = "Name of the Lambda function running the MCP server"
  value       = module.lambda.function_name
}

output "lambda_layer_arn" {
  description = "ARN of the Lambda layer containing Python dependencies"
  value       = module.lambda_layer.layer_arn
}

output "api_gateway_endpoint" {
  description = "API Gateway endpoint URL for accessing the MCP server"
  value       = module.api_gateway.api_endpoint
}

output "cognito_client_secret_name" {
  description = "Name of the AWS Secrets Manager secret containing Cognito OAuth2 client credentials"
  value       = module.cognito.client_secret_name
}

