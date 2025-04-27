output "role_name" {
  value = aws_iam_role.kubernetes_ec2_creator.name
}

output "role_arn" {
  value = aws_iam_role.kubernetes_ec2_creator.arn
}

output "policy_arn" {
  value = aws_iam_policy.kubernetes_ec2_creator_policy.arn
}
