output "vpc_id" {
  description = "VPC の ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "プライベートサブネットの ID リスト"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "パブリックサブネットの ID リスト"
  value       = module.vpc.public_subnets
}

output "vpc_cidr_block" {
  description = "VPC の CIDR ブロック"
  value       = module.vpc.vpc_cidr_block
}

output "private_route_table_ids" {
  description = "プライベートルートテーブルの ID リスト"
  value       = module.vpc.private_route_table_ids
}

output "aws_default_security_group_id" {
  description = "デフォルトセキュリティグループの ID"
  value       = module.vpc.default_security_group_id
}