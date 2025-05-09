output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state."
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking."
  value       = aws_dynamodb_table.terraform_locks.name
}

output "terraform_backend_full_access_policy_arn" {
  value = aws_iam_policy.terraform_backend_full_access.arn
}

output "terraform_backend_readonly_access_policy_arn" {
  value = aws_iam_policy.terraform_backend_readonly_access.arn
}
