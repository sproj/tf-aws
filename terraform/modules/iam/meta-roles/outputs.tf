output "infrastructure_creator_role_arn" {
  description = "ARN of the infrastructure creator role"
  value       = aws_iam_role.infrastructure_creator.arn
}

output "infrastructure_manager_role_arn" {
  description = "ARN of the infrastructure manager role"
  value       = aws_iam_role.infrastructure_manager.arn
}

output "infrastructure_reader_role_arn" {
  description = "ARN of the infrastructure reader role"
  value       = aws_iam_role.infrastructure_reader.arn
}

output "infrastructure_creator_role_name" {
  description = "Name of the infrastructure creator role"
  value       = aws_iam_role.infrastructure_creator.name
}

output "infrastructure_manager_role_name" {
  description = "Name of the infrastructure manager role"
  value       = aws_iam_role.infrastructure_manager.name
}

output "infrastructure_reader_role_name" {
  description = "Name of the infrastructure reader role"
  value       = aws_iam_role.infrastructure_reader.name
}