variable "function_name" {
  description = "Lambda関数名"
  type        = string
}

variable "s3_bucket_name" {
  description = "Lambda関数コードアップロード用S3バケット名"
  type        = string
}

variable "s3_key" {
  description = "Lambda関数コードアップロード用S3オブジェクトキー"
  type        = string
}

variable "s3_bucket_arn" {
  description = "Lambda関数コードアップロード用S3バケットARN"
  type        = string
}

variable "handler" {
  description = "Lambdaハンドラ"
  type        = string
}

variable "runtime" {
  description = "実行ランタイム"
  type        = string
  default     = "python3.12"
}

variable "vpc_subnet_ids" {
  description = "VPCのサブネットID一覧"
  type        = list(string)
  default     = []
}

variable "vpc_security_group_id" {
  description = "VPCのセキュリティグループID"
  type        = string
}

variable "layers" {
  description = "使用するLayerのARNリスト"
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  description = "Lambda環境変数"
  type        = map(string)
  default     = {}
}

variable "memory_size" {
  description = "Lambda関数のメモリサイズ（MB）"
  type        = number
  default     = 256
}

variable "timeout" {
  description = "Lambda関数のタイムアウト（秒）"
  type        = number
  default     = 60
}

variable "reserved_concurrent_executions" {
  description = "Lambda関数の予約済み同時実行数"
  type        = number
  default     = -1 # -1 means no specific limit
}