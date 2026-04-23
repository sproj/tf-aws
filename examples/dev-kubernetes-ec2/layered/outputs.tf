output "master_public_ip" {
  description = "Public IP of the Kubernetes control plane node"
  value       = module.control_plane.master_public_ip
}

output "master_private_ip" {
  description = "Private IP of the Kubernetes control plane node"
  value       = module.control_plane.master_private_ip
}

output "vpc_id" {
  description = "ID of the VPC created by base_infrastructure"
  value       = module.base_infrastructure.vpc_id
}
