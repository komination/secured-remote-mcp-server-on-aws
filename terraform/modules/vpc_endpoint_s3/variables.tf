variable "vpc_id" {
  description = "VPCのID"
  type        = string
}

variable "route_table_ids" {
  description = "VPCエンドポイントに関連付けるルートテーブルIDのリスト"
  type        = list(string)
}