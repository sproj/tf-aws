variable "name_prefix" {
  description = "Prefix for resource naming and access control."
  type        = string
}

variable "bootstrapper_user_name" {
  description = "IAM user allowed to assume this role."
  type        = string
}
