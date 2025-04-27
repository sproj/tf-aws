variable "name_prefix" {
  description = "Prefix for resource naming and access control."
  type        = string
}

variable "bootstrapper_user_name" {
  description = "IAM user allowed to assume these roles."
  type        = string
}

variable "aws_region" {
  description = "AWS Region for Terraform operations."
  type        = string
  default     = "eu-west-1"
}
