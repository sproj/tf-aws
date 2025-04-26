variable "aws_region" {
  description = "AWS region for state backend resources."
  type        = string
  default     = "eu-west-1"
}

variable "env" {
  description = "Environment name (e.g., dev, prod)."
  type        = string
}

variable "s3_bucket_name" {
  description = "Name for the Terraform state S3 bucket."
  type        = string
}

variable "dynamodb_table_name" {
  description = "Name for the DynamoDB table used for state locking."
  type        = string
}
