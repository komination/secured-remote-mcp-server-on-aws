variable "stage" {
  type        = string
  description = "stage: dev, stg, prd"
}
variable "vpc_cidr" {
  type        = string
  description = "VPC の CIDR"
}