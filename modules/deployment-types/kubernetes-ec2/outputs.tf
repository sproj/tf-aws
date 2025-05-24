output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.base_infrastructure.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.base_infrastructure.public_subnet_ids
}

output "node_security_group_ids" {
  description = "Security group IDs for Kubernetes worker nodes"
  value       = module.base_infrastructure.node_security_group_ids
}

output "master_security_group_ids" {
  description = "Security group IDs for Kubernetes master node"
  value       = module.base_infrastructure.master_security_group_ids
}

output "instance_profile_name" {
  description = "IAM instance profile name for EC2 nodes"
  value       = module.base_infrastructure.instance_profile_name
}

output "node_asg_name" {
  description = "Auto Scaling Group name for worker nodes"
  value       = module.worker_nodes.worker_asg_name
}

output "master_instance_id" {
  description = "Instance ID of the Kubernetes master node"
  value       = module.control_plane.instance_id
}

output "master_public_ip" {
  description = "Public IP address of the Kubernetes master node"
  value       = module.control_plane.public_ip
}

output "master_private_ip" {
  description = "Private IP address of the Kubernetes master node"
  value       = module.control_plane.master_private_ip
}
