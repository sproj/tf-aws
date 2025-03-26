variable "account_id" {
  description = "The AWS account ID where the roles will be created"
  type        = string
}

variable "environment" {
  description = "The environment where these roles will be used (e.g., dev, test, prod)"
  type        = string
}

variable "trusted_principal_arns" {
  description = "List of ARNs of IAM principals that can assume these roles"
  type        = list(string)
  default     = []
}