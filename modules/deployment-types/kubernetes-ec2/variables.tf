variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
## networking + SG
variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
}

## ec2-nodes
variable "node_ami_id" {
  description = "AMI ID for the Kubernetes worker nodes"
  type        = string
  # No default, as this is region and use-case specific (e.g., EKS optimized AMI or Ubuntu)
}

variable "node_instance_type" {
  description = "EC2 instance type for the worker nodes"
  type        = string
  default     = "t3.small"
}

variable "node_desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 1
}

## ec2-master
variable "master_ami_id" {
  description = "AMI ID for the Kubernetes master node"
  type        = string
}

variable "master_instance_type" {
  description = "EC2 instance type for the master node"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "SSH key name for EC2 access"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block to allow SSH access from (your IP address)"
  type        = string
  # default     = "0.0.0.0/0"
}