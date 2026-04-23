variable "allowed_ssh_cidr" {
  description = "CIDR block to allow SSH access from (your IP address)"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for this env for things like ssh key names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for ec2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "asg_desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "asg_max_capacity" {
  description = "Maximum allowed number of worker nodes"
  type        = number
  default     = 3
}

variable "root_volume_size" {
  description = "Volume size of /dev/sda1 on worker nodes"
  default     = 16
  type        = number
}

variable "public_subnet_ids" {
  description = "IDs of public subnets for worker nodes"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs to attach to worker nodes"
  type        = list(string)
}

variable "instance_profile_name" {
  description = "IAM instance profile name for worker nodes"
  type        = string
}
