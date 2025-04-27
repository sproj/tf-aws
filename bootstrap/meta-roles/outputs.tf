output "infrastructure_manager_role_name" {
  description = "Name of the infrastructure-manager role."
  value       = aws_iam_role.infrastructure_manager.name
}

output "infrastructure_manager_role_arn" {
  description = "ARN of the infrastructure-manager role."
  value       = aws_iam_role.infrastructure_manager.arn
}

output "infrastructure_manager_policy_arn" {
  description = "ARN of the policy attached to infrastructure-manager."
  value       = aws_iam_policy.infrastructure_manager_policy.arn
}
