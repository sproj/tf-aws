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

variable "allowed_ssh_cidr" {
  description = "CIDR block to allow SSH access from (your IP address)"
  type        = string
  # default     = "0.0.0.0/0"
}
