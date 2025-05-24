variable "allowed_ssh_cidr" {
  description = "CIDR block to allow SSH access from (your IP address)"
  type        = string
  # default     = "0.0.0.0/0"
}

# Should be defined in a .auto.tfvars (gitignored)
variable "name_prefix" {
  description = "Prefix for this env for things like ssh key names"
  type        = string
}
