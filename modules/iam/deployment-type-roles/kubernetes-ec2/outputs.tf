output "creator_role_name" {
  value = module.creator.role_name
}

output "creator_role_arn" {
  value = module.creator.role_arn
}

output "creator_networking_policy_arn" {
  value = module.creator.creator_networking_policy_arn
}

output "creator_ec2_policy_arn" {
  value = module.creator.creator_ec2_policy_arn
}

output "creator_elasticloadbalancing_policy_arn" {
  value = module.creator.creator_elasticloadbalancing_policy_arn
}

output "creator_autoscaling_policy_arn" {
  value = module.creator.creator_autoscaling_policy_arn
}

output "creator_iam_policy_arn" {
  value = module.creator.creator_iam_policy_arn
}

output "creator_ecr_policy_arn" {
  value = module.creator.creator_ecr_policy_arn
}

output "manager_role_name" {
  value = module.manager.role_name
}

output "manager_role_arn" {
  value = module.manager.role_arn
}

output "manager_networking_policy_arn" {
  value = module.manager.manager_networking_policy_arn
}

output "manager_ec2_policy_arn" {
  value = module.manager.manager_ec2_policy_arn
}

output "manager_elasticloadbalancing_policy_arn" {
  value = module.manager.manager_elasticloadbalancing_policy_arn
}

output "manager_autoscaling_policy_arn" {
  value = module.manager.manager_autoscaling_policy_arn
}

output "manager_iam_policy_arn" {
  value = module.manager.manager_iam_policy_arn
}

output "manager_ecr_policy_arn" {
  value = module.manager.manager_ecr_policy_arn
}

output "reader_role_name" {
  value = module.reader.role_name
}

output "reader_role_arn" {
  value = module.reader.role_arn
}

output "reader_networking_policy_arn" {
  value = module.reader.reader_networking_policy_arn
}

output "reader_ec2_policy_arn" {
  value = module.reader.reader_ec2_policy_arn
}

output "reader_elasticloadbalancing_policy_arn" {
  value = module.reader.reader_elasticloadbalancing_policy_arn
}

output "reader_autoscaling_policy_arn" {
  value = module.reader.reader_autoscaling_policy_arn
}

output "reader_iam_policy_arn" {
  value = module.reader.reader_iam_policy_arn
}

output "reader_ecr_policy_arn" {
  value = module.reader.reader_ecr_policy_arn
}

output "creator_profile_snippet" {
  description = "AWS CLI profile snippet for creator role"
  value       = <<EOT
[profile kubernetes-ec2-creator]
role_arn = ${module.creator.role_arn}
source_profile = ${var.bootstrapper_role_name}
region = ${var.aws_region}
EOT
}

output "manager_profile_snippet" {
  description = "AWS CLI profile snippet for manager role"
  value       = <<EOT
[profile kubernetes-ec2-manager]
role_arn = ${module.manager.role_arn}
source_profile = ${var.bootstrapper_role_name}
region = ${var.aws_region}
EOT
}

output "reader_profile_snippet" {
  description = "AWS CLI profile snippet for reader role"
  value       = <<EOT
[profile kubernetes-ec2-reader]
role_arn = ${module.reader.role_arn}
source_profile = ${var.bootstrapper_role_name}
region = ${var.aws_region}
EOT
}
