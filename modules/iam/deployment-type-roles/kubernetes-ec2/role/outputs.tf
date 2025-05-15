output "role_name" {
  value = aws_iam_role.deployment_role.name
}

output "role_arn" {
  value = aws_iam_role.deployment_role.arn
}

output "policy_name" {
  value = aws_iam_policy.policy.name
}

output "policy_arn" {
  value = aws_iam_policy.policy.arn
}
