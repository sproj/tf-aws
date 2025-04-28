output "role_name" {
  value = aws_iam_role.kubernetes_ec2_creator.name
}

output "role_arn" {
  value = aws_iam_role.kubernetes_ec2_creator.arn
}

output "creator_ec2_policy_arn" {
  description = "ARN of the EC2 IAM policy attached to the kubernetes-ec2-creator role"
  value       = aws_iam_policy.kubernetes_ec2_creator_ec2_policy.arn
}

output "creator_networking_policy_arn" {
  description = "ARN of the networking IAM policy attached to the kubernetes-ec2-creator role"
  value       = aws_iam_policy.kubernetes_ec2_creator_networking_policy.arn
}

output "creator_elasticloadbalancing_policy_arn" {
  description = "ARN of the Elastic Load Balancing IAM policy attached to the kubernetes-ec2-creator role"
  value       = aws_iam_policy.kubernetes_ec2_creator_elasticloadbalancing_policy.arn
}

output "creator_autoscaling_policy_arn" {
  description = "ARN of the AutoScaling IAM policy attached to the kubernetes-ec2-creator role"
  value       = aws_iam_policy.kubernetes_ec2_creator_autoscaling_policy.arn
}

output "creator_iam_policy_arn" {
  description = "ARN of the IAM policy attached to the kubernetes-ec2-creator role"
  value       = aws_iam_policy.kubernetes_ec2_creator_iam_policy.arn
}

output "creator_ecr_policy_arn" {
  description = "ARN of the ECR IAM policy attached to the kubernetes-ec2-creator role"
  value       = aws_iam_policy.kubernetes_ec2_creator_ecr_policy.arn
}

