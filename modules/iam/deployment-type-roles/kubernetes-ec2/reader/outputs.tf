output "role_name" {
  value = aws_iam_role.kubernetes_ec2_reader.name
}

output "role_arn" {
  value = aws_iam_role.kubernetes_ec2_reader.arn
}

output "reader_ec2_policy_arn" {
  description = "ARN of the EC2 IAM policy attached to the kubernetes-ec2-reader role"
  value       = aws_iam_policy.kubernetes_ec2_reader_ec2_policy.arn
}

output "reader_networking_policy_arn" {
  description = "ARN of the networking IAM policy attached to the kubernetes-ec2-reader role"
  value       = aws_iam_policy.kubernetes_ec2_reader_networking_policy.arn
}

output "reader_elasticloadbalancing_policy_arn" {
  description = "ARN of the Elastic Load Balancing IAM policy attached to the kubernetes-ec2-reader role"
  value       = aws_iam_policy.kubernetes_ec2_reader_elasticloadbalancing_policy.arn
}

output "reader_autoscaling_policy_arn" {
  description = "ARN of the AutoScaling IAM policy attached to the kubernetes-ec2-reader role"
  value       = aws_iam_policy.kubernetes_ec2_reader_autoscaling_policy.arn
}

output "reader_iam_policy_arn" {
  description = "ARN of the IAM policy attached to the kubernetes-ec2-reader role"
  value       = aws_iam_policy.kubernetes_ec2_reader_iam_policy.arn
}

output "reader_ecr_policy_arn" {
  description = "ARN of the ECR IAM policy attached to the kubernetes-ec2-reader role"
  value       = aws_iam_policy.kubernetes_ec2_reader_ecr_policy.arn
}

