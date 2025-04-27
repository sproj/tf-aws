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
  description = "List of ARNs of IAM roles that can assume these S3 resource roles"
  type        = list(string)
  default     = []
}

variable "specific_bucket_arns" {
  description = "List of specific S3 bucket ARNs to restrict access to (if empty, access is granted to all buckets)"
  type        = list(string)
  default     = []
}

variable "enable_kubernetes_etcd_backup" {
  description = "Whether to enable permissions for Kubernetes etcd backup to S3"
  type        = bool
  default     = false
}

variable "etcd_backup_bucket_arn" {
  description = "ARN of the S3 bucket for Kubernetes etcd backups (required if enable_kubernetes_etcd_backup is true)"
  type        = string
  default     = ""
}
