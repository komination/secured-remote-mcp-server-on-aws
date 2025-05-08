output "bucket_id" {
  description = "S3バケットのID及び名前"
  value       = module.s3_bucket.s3_bucket_id
}

output "bucket_arn" {
  description = "S3バケットのARN"
  value       = module.s3_bucket.s3_bucket_arn
}

output "bucket_domain_name" {
  description = "S3バケットのドメイン名"
  value       = module.s3_bucket.s3_bucket_bucket_domain_name
}