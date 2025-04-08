variable "external_id" {
  description = "External ID provided by Cloudtrim for secure cross-account role assumption"
  type        = string

  validation {
    condition     = length(var.external_id) >= 12
    error_message = "External ID must be at least 12 characters long for security purposes."
  }
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-\\d{1}$", var.region))
    error_message = "Region must be a valid AWS region name (e.g., us-east-1, eu-west-1)."
  }
}

variable "role_name" {
  description = "Name of the IAM role to be created"
  type        = string
  default     = "CloudtrimAccessRole"

  validation {
    condition     = can(regex("^[\\w+=,.@-]{1,64}$", var.role_name))
    error_message = "Role name must be valid IAM role name format and max 64 characters."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
