// VPCエンドポイントのリソースID
output "vpc_endpoint_id" {
  description = "作成されたVPCエンドポイントのID"
  value       = aws_vpc_endpoint.s3.id
}

// S3 GatewayエンドポイントのPrefix List ID
output "prefix_list_id" {
  description = "S3 GatewayエンドポイントのPrefix List ID"
  value       = aws_vpc_endpoint.s3.prefix_list_id
}