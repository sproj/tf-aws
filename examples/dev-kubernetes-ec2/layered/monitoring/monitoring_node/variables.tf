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
  default     = 1
}

variable "root_volume_size" {
  description = "Volume size of /dev/sda1 on worker nodes"
  type        = number
}
