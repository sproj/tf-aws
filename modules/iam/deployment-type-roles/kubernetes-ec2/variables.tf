variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "k8s"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "enable_irsa" {
  description = "Whether to enable IAM Roles for Service Accounts (IRSA)"
  type        = bool
  default     = false
}

variable "eks_oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster (required if enable_irsa is true)"
  type        = string
  default     = ""
}

variable "eks_oidc_provider_thumbprint" {
  description = "Thumbprint of the OIDC provider (required if enable_irsa is true)"
  type        = list(string)
  default     = []
}

variable "additional_policy_arns" {
  description = "List of additional policy ARNs to attach to the Kubernetes worker role"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region where resources are deployed"
  type        = string
  default     = "us-west-2"
}

variable "vpc_id" {
  description = "ID of the VPC where Kubernetes cluster will be deployed"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs for Kubernetes cluster"
  type        = list(string)
  default     = []
}