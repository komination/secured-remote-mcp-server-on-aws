output "lambda_endpoint_id" {
  description = "作成されたLambda VPCエンドポイントのID"
  value       = aws_vpc_endpoint.lambda.id
}

output "lambda_dns_entries" {
  description = "Lambda VPCエンドポイントのDNSエントリ"
  value       = aws_vpc_endpoint.lambda.dns_entry
}