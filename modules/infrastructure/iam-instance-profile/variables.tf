variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "service_name" {
  description = "The AWS service that will assume this role"
  type        = string
}

variable "service_identifiers" {
  description = "List of service identifiers that can assume this role"
  type        = list(string)
}
