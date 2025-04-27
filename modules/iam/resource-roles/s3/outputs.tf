output "s3_creator_role_arn" {
  description = "ARN of the S3 creator role"
  value       = aws_iam_role.s3_creator.arn
}

output "s3_creator_role_name" {
  description = "Name of the S3 creator role"
  value       = aws_iam_role.s3_creator.name
}

output "s3_manager_role_arn" {
  description = "ARN of the S3 manager role"
  value       = aws_iam_role.s3_manager.arn
}

output "s3_manager_role_name" {
  description = "Name of the S3 manager role"
  value       = aws_iam_role.s3_manager.name
}

output "s3_reader_role_arn" {
  description = "ARN of the S3 reader role"
  value       = aws_iam_role.s3_reader.arn
}

output "s3_reader_role_name" {
  description = "Name of the S3 reader role"
  value       = aws_iam_role.s3_reader.name
}

output "s3_creator_policy_arn" {
  description = "ARN of the S3 creator policy"
  value       = length(var.specific_bucket_arns) > 0 ? aws_iam_policy.s3_creator_specific_buckets_policy[0].arn : aws_iam_policy.s3_creator_policy.arn
}

output "s3_manager_policy_arn" {
  description = "ARN of the S3 manager policy"
  value       = length(var.specific_bucket_arns) > 0 ? aws_iam_policy.s3_manager_specific_buckets_policy[0].arn : aws_iam_policy.s3_manager_policy.arn
}

output "s3_reader_policy_arn" {
  description = "ARN of the S3 reader policy"
  value       = length(var.specific_bucket_arns) > 0 ? aws_iam_policy.s3_reader_specific_buckets_policy[0].arn : aws_iam_policy.s3_reader_policy.arn
}

output "kubernetes_etcd_backup_policy_arn" {
  description = "ARN of the Kubernetes etcd backup policy (if enabled)"
  value       = var.enable_kubernetes_etcd_backup ? aws_iam_policy.kubernetes_etcd_backup_policy[0].arn : ""
}
