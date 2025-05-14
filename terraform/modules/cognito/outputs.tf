output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.this.id
}

output "temp_username" {
  description = "Username of the temporary test user"
  value       = random_string.username.result
}

output "temp_password" {
  description = "Temporary password for the test user"
  value       = random_password.password.result
  sensitive   = true
}
