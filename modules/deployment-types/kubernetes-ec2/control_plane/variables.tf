variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the instance"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 nodes"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

## ec2-master
variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 1
}

variable "ami_id" {
  description = "AMI ID for the Kubernetes master node"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the master node"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key name for EC2 access"
  type        = string
}

## k8s master node specific
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
  default     = "0.26.7" # Current stable version
}
