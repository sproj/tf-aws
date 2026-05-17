variable "aws_region" {
  description = "AWS Region for Terraform operations."
  type        = string
  default     = "eu-west-1"
}

variable "env" {
  description = "Short form for the environment name (dev, staging, prod...)"
  type        = string
}

variable "name_prefix" {
  description = "Cluster name prefix used in SSM parameter paths."
  type        = string
}
