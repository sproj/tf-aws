output "ec2_creator_role_arn" {
  description = "ARN of the EC2 creator role"
  value       = aws_iam_role.ec2_creator.arn
}

output "ec2_creator_role_name" {
  description = "Name of the EC2 creator role"
  value       = aws_iam_role.ec2_creator.name
}

output "ec2_manager_role_arn" {
  description = "ARN of the EC2 manager role"
  value       = aws_iam_role.ec2_manager.arn
}

output "ec2_manager_role_name" {
  description = "Name of the EC2 manager role"
  value       = aws_iam_role.ec2_manager.name
}

output "ec2_reader_role_arn" {
  description = "ARN of the EC2 reader role"
  value       = aws_iam_role.ec2_reader.arn
}

output "ec2_reader_role_name" {
  description = "Name of the EC2 reader role"
  value       = aws_iam_role.ec2_reader.name
}

output "ec2_creator_policy_arn" {
  description = "ARN of the EC2 creator policy"
  value       = aws_iam_policy.ec2_creator_policy.arn
}

output "ec2_manager_policy_arn" {
  description = "ARN of the EC2 manager policy"
  value       = aws_iam_policy.ec2_manager_policy.arn
}

output "ec2_reader_policy_arn" {
  description = "ARN of the EC2 reader policy"
  value       = aws_iam_policy.ec2_reader_policy.arn
}

output "ec2_ssm_access_policy_arn" {
  description = "ARN of the EC2 SSM access policy"
  value       = var.enable_ssm_access ? aws_iam_policy.ec2_ssm_access_policy[0].arn : ""
}