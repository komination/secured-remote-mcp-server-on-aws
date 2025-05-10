variable "s3_bucket_name" {
  description = "Lambda Layerのコードアップロード用S3バケット名"
  type        = string
}

variable "s3_key" {
  description = "Lambda Layerのコードアップロード用S3オブジェクトキー"
  type        = string
}

variable "runtime" {
  description = "実行ランタイム"
  type        = string
  default     = "python3.12"
}

variable "layer_name" {
  description = "Lambda Layerの名前"
  type        = string
}