# env wide vars
variable "name_prefix" {
  description = "Prefix for this env for things like ssh key names"
  type        = string
}

variable "env" {
  description = "Short form environment name (dev, prod...)"
  type        = string
}

# base infra vars
variable "allowed_ssh_cidr" {
  description = "CIDR block to allow SSH access from (your IP address)"
  type        = string
  # default     = "0.0.0.0/0"
}

# control plane vars
variable "ami_id" {
  description = "AMI ID for ec2 instances"
  type        = string
}

variable "control_plane_instance_type" {
  description = "EC2 instance type for the master node"
  type        = string
  default     = "t3.small"
}

variable "control_plane_root_volume_size" {
  description = "Volume size of /dev/sda1 on nodes"
  default     = 8
  type        = number
}

# worker_node vars
variable "worker_instance_type" {
  description = "EC2 instance type for the master node"
  type        = string
  default     = "t3.medium"
}

variable "worker_root_volume_size" {
  description = "Volume size of /dev/sda1 on nodes"
  default     = 16
  type        = number
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
