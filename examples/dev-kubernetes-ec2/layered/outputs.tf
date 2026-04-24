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

output "ssh_command" {
  description = "SSH command to connect to the master node"
  value       = "ssh -i ~/.ssh/${var.name_prefix}-key ubuntu@${module.control_plane.master_public_ip}"
}

output "start_k8s_tunnel_command" {
  description = "Command to start the SSH tunnel for kubectl access"
  value       = "bash start-k8s-tunnel.sh ${module.control_plane.master_public_ip} ${module.control_plane.master_private_ip} ${var.name_prefix}-key 6443"
}

output "check_initialization_command" {
  description = "Command to check the initialization status of the cluster"
  value       = "./check-k8s-init.sh ${module.control_plane.master_public_ip} ~/.ssh/${var.name_prefix}-key"
}

output "merge_kubeconfig_command" {
  description = "Command to merge kubeconfig from the deployed cluster"
  value       = "./merge_kubeconfig.sh ${var.name_prefix} ${module.control_plane.master_public_ip} ${module.control_plane.master_private_ip}"
}