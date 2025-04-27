output "networking_creator_role_arn" {
  description = "ARN of the networking creator role"
  value       = aws_iam_role.networking_creator.arn
}

output "networking_creator_role_name" {
  description = "Name of the networking creator role"
  value       = aws_iam_role.networking_creator.name
}

output "networking_manager_role_arn" {
  description = "ARN of the networking manager role"
  value       = aws_iam_role.networking_manager.arn
}

output "networking_manager_role_name" {
  description = "Name of the networking manager role"
  value       = aws_iam_role.networking_manager.name
}

output "networking_reader_role_arn" {
  description = "ARN of the networking reader role"
  value       = aws_iam_role.networking_reader.arn
}

output "networking_reader_role_name" {
  description = "Name of the networking reader role"
  value       = aws_iam_role.networking_reader.name
}

output "networking_creator_policy_arn" {
  description = "ARN of the networking creator policy"
  value       = aws_iam_policy.networking_creator_policy.arn
}

output "networking_manager_policy_arn" {
  description = "ARN of the networking manager policy"
  value       = aws_iam_policy.networking_manager_policy.arn
}

output "networking_reader_policy_arn" {
  description = "ARN of the networking reader policy"
  value       = aws_iam_policy.networking_reader_policy.arn
}

output "kubernetes_networking_policy_arn" {
  description = "ARN of the Kubernetes networking policy (if enabled)"
  value       = var.enable_kubernetes_networking ? aws_iam_policy.kubernetes_networking_policy[0].arn : ""
}
