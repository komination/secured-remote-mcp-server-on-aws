output "api_id" {
  description = "ID of the HTTP API"
  value       = module.api_gateway.api_id
}

output "api_endpoint" {
  description = "Invoke URL for the deployed stage"
  value       = module.api_gateway.api_endpoint
}

output "api_execution_arn" {
  description = "ARN prefix for integrations"
  value       = module.api_gateway.api_execution_arn
}

output "stage_id" {
  description = "ID of the default stage"
  value       = module.api_gateway.stage_id
}
