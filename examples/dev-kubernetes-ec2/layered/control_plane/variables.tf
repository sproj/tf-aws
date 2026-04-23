variable "name_prefix" {
  description = "Prefix for this env for things like ssh key names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for ec2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the control plane node"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Volume size of /dev/sda1 on the control plane node"
  default     = 8
  type        = number
}

variable "public_subnet_ids" {
  description = "IDs of public subnets for the control plane node"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs to attach to the control plane node"
  type        = list(string)
}

variable "instance_profile_name" {
  description = "IAM instance profile name for the control plane node"
  type        = string
}
