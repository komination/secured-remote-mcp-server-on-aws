variable "vpc_id" {
  description = "VPCのID"
  type        = string
}

variable "lambda_subnet_ids" {
  description = "Lambda VPCエンドポイントに関連付けるサブネットIDのリスト"
  type        = list(string)
}

variable "lambda_security_group_ids" {
  description = "Lambda VPCエンドポイントに関連付けるセキュリティグループIDのリスト"
  type        = list(string)
}