output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.base_infrastructure.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.base_infrastructure.public_subnet_ids
}

output "node_security_group_id" {
  description = "Security group IDs for Kubernetes worker nodes"
  value       = module.base_infrastructure.node_security_group_id
}

output "master_security_group_id" {
  description = "Security group IDs for Kubernetes master node"
  value       = module.base_infrastructure.master_security_group_id
}

output "instance_profile_name" {
  description = "IAM instance profile name for EC2 nodes"
  value       = module.base_infrastructure.instance_profile_name
}
