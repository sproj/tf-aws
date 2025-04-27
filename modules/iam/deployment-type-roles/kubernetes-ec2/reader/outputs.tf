output "role_name" {
  value = aws_iam_role.kubernetes_ec2_reader.name
}

output "role_arn" {
  value = aws_iam_role.kubernetes_ec2_reader.arn
}

output "policy_arn" {
  value = aws_iam_policy.kubernetes_ec2_reader_policy.arn
}
