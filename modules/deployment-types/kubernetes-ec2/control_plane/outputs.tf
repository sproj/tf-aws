output "instance_id" {
  value = module.master_instance.instance_id
}

output "public_ip" {
  value = module.master_instance.public_ip
}

output "master_private_ip" {
  description = "Private IP address of the Kubernetes master node"
  value       = module.master_instance.private_ip
}
