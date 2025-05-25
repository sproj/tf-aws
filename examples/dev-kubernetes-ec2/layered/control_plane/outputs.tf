output "master_public_ip" {
  description = "Public IP address of the Kubernetes master node. Use this to SSH in and access the dashboard."
  value       = module.control_plane.public_ip
}

output "master_private_ip" {
  description = "Private IP address of the Kubernetes master node."
  value       = module.control_plane.master_private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the master node"
  value       = "ssh -i ~/.ssh/${var.name_prefix}-key ubuntu@${module.control_plane.public_ip}"
}

output "start_k8s_tunnel_command" {
  description = "Command to start the SSH tunnel for kubectl access"
  value       = "bash start-k8s-tunnel.sh ${module.control_plane.public_ip} ${module.control_plane.master_private_ip} ${var.name_prefix}-key 6443"
}

output "check_initialization_command" {
  description = "Command to check the initialization status of the cluster"
  value       = "./check-k8s-init.sh ${module.control_plane.public_ip} ~/.ssh/${var.name_prefix}-key"
}

output "merge_kubeconfig_command" {
  description = "Command to merge kubeconfig from the deployed cluster"
  value       = "./merge_kubeconfig.sh ${var.name_prefix} ${module.control_plane.public_ip}"
}
