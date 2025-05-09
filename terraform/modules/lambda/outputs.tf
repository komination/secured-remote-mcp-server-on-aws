// Outputs for Lambda module
output "function_name" {
  description = "Lambda関数名"
  value       = module.lambda.lambda_function_name
}

output "function_arn" {
  description = "Lambda関数のARN"
  value       = module.lambda.lambda_function_arn
}