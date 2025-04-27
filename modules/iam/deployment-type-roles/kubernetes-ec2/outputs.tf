output "kubernetes_worker_role_arn" {
  description = "ARN of the IAM role used by Kubernetes worker nodes"
  value       = aws_iam_role.kubernetes_worker_node.arn
}

output "kubernetes_worker_role_name" {
  description = "Name of the IAM role used by Kubernetes worker nodes"
  value       = aws_iam_role.kubernetes_worker_node.name
}

output "kubernetes_worker_instance_profile_arn" {
  description = "ARN of the IAM instance profile used by Kubernetes worker nodes"
  value       = aws_iam_instance_profile.kubernetes_worker_profile.arn
}

output "kubernetes_worker_instance_profile_name" {
  description = "Name of the IAM instance profile used by Kubernetes worker nodes"
  value       = aws_iam_instance_profile.kubernetes_worker_profile.name
}

output "kubernetes_oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA (if enabled)"
  value       = var.enable_irsa ? aws_iam_openid_connect_provider.kubernetes[0].arn : ""
}

output "kubernetes_ec2_policy_arn" {
  description = "ARN of the EC2 policy for Kubernetes worker nodes"
  value       = aws_iam_policy.kubernetes_ec2_policy.arn
}

output "kubernetes_elb_policy_arn" {
  description = "ARN of the ELB policy for Kubernetes worker nodes"
  value       = aws_iam_policy.kubernetes_elb_policy.arn
}

output "kubernetes_ecr_policy_arn" {
  description = "ARN of the ECR policy for Kubernetes worker nodes"
  value       = aws_iam_policy.kubernetes_ecr_policy.arn
}

output "kubernetes_iam_auth_policy_arn" {
  description = "ARN of the IAM Authenticator policy for Kubernetes worker nodes"
  value       = aws_iam_policy.kubernetes_iam_auth_policy.arn
}