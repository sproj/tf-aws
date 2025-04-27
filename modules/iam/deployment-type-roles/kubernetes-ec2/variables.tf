variable "bootstrapper_role_name" {
  description = "IAM user allowed to assume these roles."
  type        = string
}

variable "aws_region" {
  description = "AWS Region for Terraform operations."
  type        = string
  default     = "eu-west-1"
}
