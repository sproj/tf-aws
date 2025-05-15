variable "name_prefix" {
  description = "Prefix for security group names"
  type        = string
}

variable "tags" {
  description = "Tags to apply to security groups"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID to associate security groups with"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
}
