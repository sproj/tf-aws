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
  description = "List of ARNs of IAM roles that can assume these networking resource roles"
  type        = list(string)
  default     = []
}

variable "enable_kubernetes_networking" {
  description = "Whether to enable additional permissions for Kubernetes networking (AWS Load Balancer Controller, CNI plugins)"
  type        = bool
  default     = false
}
