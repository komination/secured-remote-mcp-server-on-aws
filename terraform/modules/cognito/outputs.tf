output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.this.id
}

output "scope_read" {
  description = "Full scope string for read access"
  value       = "${aws_cognito_resource_server.api.identifier}/read"
}

output "client_secret_name" {
  description = "Name of the AWS Secrets Manager secret containing Cognito client credentials"
  value       = aws_secretsmanager_secret.client_secret.name
}