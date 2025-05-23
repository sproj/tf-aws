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

output "node_asg_name" {
  description = "Auto Scaling Group name for worker nodes"
  value       = module.ec2_nodes.asg_name
}

output "master_instance_id" {
  description = "Instance ID of the Kubernetes master node"
  value       = module.ec2_master.instance_id
}

output "master_public_ip" {
  description = "Public IP address of the Kubernetes master node"
  value       = module.ec2_master.public_ip
}

output "master_private_ip" {
  description = "Private IP address of the Kubernetes master node"
  value = module.ec2_master.master_private_ip
}