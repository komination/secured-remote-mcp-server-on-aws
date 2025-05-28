variable "name_prefix" {
  description = "Prefix for all Cognito resources"
  type        = string
}

variable "recovery_window_in_days" {
  description = "Number of days to retain the secret before it can be deleted"
  type        = number
  default     = 0
}