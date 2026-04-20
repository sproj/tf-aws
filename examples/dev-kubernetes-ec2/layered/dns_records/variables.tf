variable "aws_region" {
  description = "AWS Region for Terraform operations."
  type        = string
  default     = "eu-west-1"
}

variable "env" {
  description = "Short form for the environment name (dev, staging, prod...)"
  type        = string
}

variable "name_prefix" {
  type = string
}

variable "the_domain_name" {
  description = "The human readable domain you will be navigating to"
  type        = string
}

variable "nlb_zone_id" {
  description = "Hosted zone ID of the NLB (provided by AWS, not the Route53 zone)"
  type        = string
}

