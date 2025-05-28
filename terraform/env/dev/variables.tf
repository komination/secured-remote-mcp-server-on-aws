variable "lambda_zip_key" {
  description = "S3 object key for the Lambda function ZIP (Run-specific)"
  type        = string
  default     = "lambda/dev-my-lambda-fn-dummy.zip"
  nullable    = false
}

variable "lambda_layer_zip_key" {
  description = "S3 object key for the Lambda layer ZIP (Run-specific)"
  type        = string
  default     = "lambda-layers/dev-my-lambda-layer-dummy.zip"
  nullable    = false
}

variable "existing_artifacts_bucket_name" {
  description = "S3 bucket for storing artifacts"
  type        = string
  default     = null
  nullable    = true
}