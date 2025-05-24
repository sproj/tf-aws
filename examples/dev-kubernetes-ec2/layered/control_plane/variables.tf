# Should be defined in a .auto.tfvars (gitignored)
variable "name_prefix" {
  description = "Prefix for this env for things like ssh key names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for ec2 instances"
  type        = string
}
