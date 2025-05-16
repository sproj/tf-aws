output "master_public_ip" {
  description = "Public IP address of the Kubernetes master node. Use this to SSH in and access the dashboard."
  value       = module.kubernetes_ec2.master_public_ip
}

output "ssh_command" {
  description = "SSH command to connect to the master node"
  value       = "ssh -i ~/.ssh/dev-k8s-key ubuntu@${module.kubernetes_ec2.master_public_ip}"
}