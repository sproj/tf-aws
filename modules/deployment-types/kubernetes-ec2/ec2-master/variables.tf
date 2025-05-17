variable "subnet_id" {
  description = "Subnet ID for the master node"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the master node"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for the master node"
  type        = string
}

variable "pod_network_cidr" {
  description = "CIDR range for pod network"
  type        = string
  default     = "10.244.0.0/16" # Default for Flannel
}

variable "service_cidr" {
  description = "CIDR range for services"
  type        = string
  default     = "10.96.0.0/12" # Kubernetes default
}

variable "kubernetes_version" {
  description = "Kubernetes version to install"
  type        = string
  default     = "1.33" # Current stable version
}

variable "cni_version" {
  description = "CNI version to install"
  type        = string
  default     = "1.3.0" # Current stable version
}

variable "ami_id" {
  description = "AMI ID for the master node"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the master node"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key name for access"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
