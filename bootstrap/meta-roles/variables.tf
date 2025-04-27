variable "aws_region" {
  description = "AWS Region for Terraform operations."
  type        = string
  default     = "eu-west-1"
}

variable "bootstrapper_user_name" {
  description = "The IAM user who can assume the infrastructure-manager role."
  type        = string
}
