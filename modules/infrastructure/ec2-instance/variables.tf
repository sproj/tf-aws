variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs for the instance"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for the instance"
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

variable "name" {
  description = "Name this instance (eg dev-k8s-master)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "user_data" {
  description = "base64 encoded string of script (if any) to be run after cloud-init"
  type        = string
  default     = ""
}

