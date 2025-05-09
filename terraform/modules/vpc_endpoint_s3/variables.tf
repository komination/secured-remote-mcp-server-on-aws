variable "vpc_id" {
  description = "VPCのID"
  type        = string
}

variable "private_route_table_ids" {
  description = "VPCエンドポイントに関連付けるプライベートルートテーブルIDのリスト"
  type        = list(string)
}

variable "allowed_bucket_arns" {
  description = "許可するS3バケットのARNリスト（バケットおよびオブジェクト両方）"
  type        = list(string)
  default     = []
}