variable "name_prefix" {
  description = "Prefix for all Cognito resources"
  type        = string
}

variable "client_name" {
  description = "Cognito User Pool Client name (optional)"
  type        = string
  default     = ""
}

variable "password_length" {
  description = "Length of the temporary user’s password"
  type        = number
  default     = 16
}

variable "password_upper" {
  description = "Include uppercase letters in temporary password"
  type        = bool
  default     = true
}

variable "password_lower" {
  description = "Include lowercase letters in temporary password"
  type        = bool
  default     = true
}

variable "password_number" {
  description = "Include numbers in temporary password"
  type        = bool
  default     = true
}

variable "password_special" {
  description = "Include special characters in temporary password"
  type        = bool
  default     = true
}

variable "enable_domain" {
  description = "Whether to create a Cognito hosted UI domain"
  type        = bool
  default     = false
}

variable "domain_prefix" {
  description = "Prefix for the Cognito domain name (optional)"
  type        = string
  default     = ""
}
