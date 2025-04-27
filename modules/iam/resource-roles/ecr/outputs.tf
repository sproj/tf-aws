output "ecr_creator_role_arn" {
  description = "ARN of the ECR creator role"
  value       = aws_iam_role.ecr_creator.arn
}

output "ecr_creator_role_name" {
  description = "Name of the ECR creator role"
  value       = aws_iam_role.ecr_creator.name
}

output "ecr_manager_role_arn" {
  description = "ARN of the ECR manager role"
  value       = aws_iam_role.ecr_manager.arn
}

output "ecr_manager_role_name" {
  description = "Name of the ECR manager role"
  value       = aws_iam_role.ecr_manager.name
}

output "ecr_reader_role_arn" {
  description = "ARN of the ECR reader role"
  value       = aws_iam_role.ecr_reader.arn
}

output "ecr_reader_role_name" {
  description = "Name of the ECR reader role"
  value       = aws_iam_role.ecr_reader.name
}

output "ecr_creator_policy_arn" {
  description = "ARN of the ECR creator policy"
  value       = length(var.specific_repository_arns) > 0 ? aws_iam_policy.ecr_creator_specific_repos_policy[0].arn : aws_iam_policy.ecr_creator_policy.arn
}

output "ecr_manager_policy_arn" {
  description = "ARN of the ECR manager policy"
  value       = length(var.specific_repository_arns) > 0 ? aws_iam_policy.ecr_manager_specific_repos_policy[0].arn : aws_iam_policy.ecr_manager_policy.arn
}

output "ecr_reader_policy_arn" {
  description = "ARN of the ECR reader policy"
  value       = length(var.specific_repository_arns) > 0 ? aws_iam_policy.ecr_reader_specific_repos_policy[0].arn : aws_iam_policy.ecr_reader_policy.arn
}

output "kubernetes_pod_ecr_policy_arn" {
  description = "ARN of the Kubernetes pod ECR policy (if enabled)"
  value       = var.enable_kubernetes_pod_identity ? aws_iam_policy.kubernetes_pod_ecr_policy[0].arn : ""
}
