output "ssm_read_policy_arn" {
  value = aws_iam_policy.ssm_read.arn
}

output "ssm_write_policy_arn" {
  value = aws_iam_policy.ssm_write.arn
}
