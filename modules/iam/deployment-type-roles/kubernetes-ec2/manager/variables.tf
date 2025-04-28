variable "bootstrapper_role_name" {
  description = "IAM user allowed to assume this role."
  type        = string
}

variable "backend_full_access_policy_arn" {
  type = string
}

variable "networking_allowed_actions" {
  type = list(string)
}
