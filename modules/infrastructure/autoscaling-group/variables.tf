variable "subnet_ids" {
  description = "List of subnet IDs for the nodes"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the nodes"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for the nodes"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the worker nodes"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "name" {
  description = "Name the autoscaling group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "user_data" {
  description = "base64encoded string of a script to run (if any) as cloud-init"
  type        = string
  default     = ""
}
