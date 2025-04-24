variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "resource"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "trusted_role_arns" {
  description = "List of ARNs of IAM roles that can assume these ECR resource roles"
  type        = list(string)
  default     = []
}

variable "specific_repository_arns" {
  description = "List of specific ECR repository ARNs to restrict access to (if empty, access is granted to all repositories)"
  type        = list(string)
  default     = []
}

variable "enable_kubernetes_pod_identity" {
  description = "Whether to enable permissions for Kubernetes pods to pull images from ECR"
  type        = bool
  default     = false
}
