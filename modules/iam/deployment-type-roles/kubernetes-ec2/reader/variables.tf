variable "bootstrapper_role_name" {
  description = "IAM user allowed to assume this role."
  type        = string
}

variable "backend_readonly_access_policy_arn" {
  type = string
}

variable "networking_allowed_actions" {
  type = list(string)
}

variable "ec2_allowed_actions" {
  type = list(string)
}

variable "elasticloadbalancing_allowed_actions" {
  type = list(string)
}

variable "autoscaling_allowed_actions" {
  type = list(string)
}

variable "iam_allowed_actions" {
  type = list(string)
}

variable "ecr_allowed_actions" {
  type = list(string)
}