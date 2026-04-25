variable "name_prefix" {
  description = "Prefix for this environment"
  type        = string
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
