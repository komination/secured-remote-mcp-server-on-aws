variable "name" {
  description = "Name of the API Gateway REST API"
  type        = string
}

variable "description" {
  description = "Description of the API Gateway REST API"
  type        = string
  default     = ""
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function to integrate with API Gateway"
  type        = string
}

variable "cors_configuration" {
  description = "CORS configuration object for HTTP API"
  type = object({
    allow_headers  = list(string)
    allow_methods  = list(string)
    allow_origins  = list(string)
    expose_headers = optional(list(string))
    max_age        = optional(number)
  })
}

variable "enable_cognito_auth" {
  description = "Enable Cognito JWT authorizer"
  type        = bool
  default     = false
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for JWT authorizer"
  type        = string
  default     = ""
}

variable "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID for JWT authorizer"
  type        = string
  default     = ""
}
