variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "resource"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "account_id" {
  description = "The AWS account ID where the roles will be created"
  type        = string
}

variable "trusted_role_arns" {
  description = "List of ARNs of IAM roles that can assume these EC2 resource roles"
  type        = list(string)
  default     = []
}

variable "enable_ssm_access" {
  description = "Whether to enable SSM access for EC2 instances"
  type        = bool
  default     = true
}
