# Should be defined in a .auto.tfvars (gitignored)
variable "name_prefix" {
  description = "Prefix for this env for things like ssh key names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for ec2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the master node"
  type        = string
  default     = "t3.small"
}

variable "root_volume_size" {
  description = "Volume size of /dev/sda1 on nodes"
  default     = 8
  type        = number
}
