output "iam_creator_role_arn" {
  description = "ARN of the IAM creator role"
  value       = aws_iam_role.iam_creator.arn
}

output "iam_creator_role_name" {
  description = "Name of the IAM creator role"
  value       = aws_iam_role.iam_creator.name
}

output "iam_manager_role_arn" {
  description = "ARN of the IAM manager role"
  value       = aws_iam_role.iam_manager.arn
}

output "iam_manager_role_name" {
  description = "Name of the IAM manager role"
  value       = aws_iam_role.iam_manager.name
}

output "iam_reader_role_arn" {
  description = "ARN of the IAM reader role"
  value       = aws_iam_role.iam_reader.arn
}

output "iam_reader_role_name" {
  description = "Name of the IAM reader role"
  value       = aws_iam_role.iam_reader.name
}

output "iam_creator_policy_arn" {
  description = "ARN of the IAM creator policy"
  value       = var.iam_path != "" ? aws_iam_policy.iam_creator_path_specific_policy[0].arn : aws_iam_policy.iam_creator_policy.arn
}

output "iam_manager_policy_arn" {
  description = "ARN of the IAM manager policy"
  value       = var.iam_path != "" ? aws_iam_policy.iam_manager_path_specific_policy[0].arn : aws_iam_policy.iam_manager_policy.arn
}

output "iam_reader_policy_arn" {
  description = "ARN of the IAM reader policy"
  value       = aws_iam_policy.iam_reader_policy.arn
}

output "kubernetes_irsa_policy_arn" {
  description = "ARN of the Kubernetes IRSA policy (if enabled)"
  value       = var.enable_kubernetes_irsa ? aws_iam_policy.kubernetes_irsa_policy[0].arn : ""
}
