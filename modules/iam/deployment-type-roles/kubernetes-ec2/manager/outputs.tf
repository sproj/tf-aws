output "role_name" {
  value = aws_iam_role.kubernetes_ec2_manager.name
}

output "role_arn" {
  value = aws_iam_role.kubernetes_ec2_manager.arn
}

output "policy_arn" {
  value = aws_iam_policy.kubernetes_ec2_manager_policy.arn
}
