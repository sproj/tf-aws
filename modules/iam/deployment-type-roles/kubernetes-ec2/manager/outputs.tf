output "role_name" {
  value = aws_iam_role.kubernetes_ec2_manager.name
}

output "role_arn" {
  value = aws_iam_role.kubernetes_ec2_manager.arn
}

output "manager_ec2_policy_arn" {
  description = "ARN of the EC2 IAM policy attached to the kubernetes-ec2-manager role"
  value       = aws_iam_policy.kubernetes_ec2_manager_ec2_policy.arn
}

output "manager_networking_policy_arn" {
  description = "ARN of the networking IAM policy attached to the kubernetes-ec2-manager role"
  value       = aws_iam_policy.kubernetes_ec2_manager_networking_policy.arn
}

output "manager_elasticloadbalancing_policy_arn" {
  description = "ARN of the Elastic Load Balancing IAM policy attached to the kubernetes-ec2-manager role"
  value       = aws_iam_policy.kubernetes_ec2_manager_elasticloadbalancing_policy.arn
}

output "manager_autoscaling_policy_arn" {
  description = "ARN of the AutoScaling IAM policy attached to the kubernetes-ec2-manager role"
  value       = aws_iam_policy.kubernetes_ec2_manager_autoscaling_policy.arn
}

output "manager_iam_policy_arn" {
  description = "ARN of the IAM policy attached to the kubernetes-ec2-manager role"
  value       = aws_iam_policy.kubernetes_ec2_manager_iam_policy.arn
}

output "manager_ecr_policy_arn" {
  description = "ARN of the ECR IAM policy attached to the kubernetes-ec2-manager role"
  value       = aws_iam_policy.kubernetes_ec2_manager_ecr_policy.arn
}

