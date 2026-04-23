variable "name_prefix" {
  type = string
}

variable "env" {
  description = "Short form environment name (dev, prod...)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "vpc_id" {
  description = "ID of the VPC where the AWS Load Balancer Controller will create load balancers"
  type        = string
}
