variable "bootstrapper_role_name" {
  description = "IAM user allowed to assume this role."
  type        = string
}

variable "backend_full_access_policy_arn" {
  type = string
}

variable "role_name" {
  type = string
}

variable "policy_name" {
  type = string
}

variable "actions" {
  description = "List of lists of permissions per infrastructure type this role can perform"
  type        = list(string)
}
