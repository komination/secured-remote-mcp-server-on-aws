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

output "intra_subnets" {
  description = "イントラサブネットの ID リスト"
  value       = module.vpc.intra_subnets
}

output "vpc_cidr_block" {
  description = "VPC の CIDR ブロック"
  value       = module.vpc.vpc_cidr_block
}

output "nat_public_ips" {
  description = "NAT Gateway の パブリック IP リスト"
  value       = module.vpc.nat_public_ips
}