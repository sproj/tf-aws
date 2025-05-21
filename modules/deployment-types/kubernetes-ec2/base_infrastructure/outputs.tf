output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "node_security_group_ids" {
  description = "Security group IDs for Kubernetes worker nodes"
  value       = module.security_groups.node_sg_ids
}

output "master_security_group_ids" {
  description = "Security group IDs for Kubernetes master node"
  value       = module.security_groups.master_sg_ids
}

output "instance_profile_name" {
  description = "IAM instance profile name for EC2 nodes"
  value       = module.iam_instance_profile.profile_name
}