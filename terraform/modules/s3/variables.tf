variable "bucket_name" {
  description = "S3バケット名"
  type        = string
}

variable "enable_versioning" {
  description = "S3バケットのバージョニングを有効にするかどうか"
  type        = bool
  default     = false
}