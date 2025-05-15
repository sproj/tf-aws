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
