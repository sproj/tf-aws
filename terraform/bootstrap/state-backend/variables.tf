variable "project_name" {
  description = "Short name for the project"
  type        = string
  default     = "tfaws"
}

variable "aws_region" {
  description = "AWS region for state backend resources."
  type        = string
  default     = "eu-west-1"
}

variable "env" {
  description = "Environment name (e.g., dev, prod)."
  type        = string
}

# S3 bucket name derived
locals {
  s3_bucket_name = "${var.project_name}-${var.env}-state-backend"
  dynamodb_table_name = "${var.project_name}-${var.env}-lock-backend"
}

