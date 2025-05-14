module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.8.0"

  bucket = var.bucket_name

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  versioning = {
    enabled = var.enable_versioning
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}