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
  description = "List of ARNs of IAM roles that can assume these IAM resource roles"
  type        = list(string)
  default     = []
}

variable "iam_path" {
  description = "IAM path to restrict permissions to (e.g., /app/, /service/)"
  type        = string
  default     = ""
}

variable "enable_kubernetes_irsa" {
  description = "Whether to enable permissions for Kubernetes IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = false
}

variable "irsa_role_path" {
  description = "IAM path for service account roles (required if enable_kubernetes_irsa is true)"
  type        = string
  default     = ""
}
