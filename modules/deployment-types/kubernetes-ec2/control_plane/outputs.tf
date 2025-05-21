output "instance_id" {
  value = module.ec2_master.aws_instance.master.id
}

output "public_ip" {
  value = module.ec2_master.aws_instance.master.public_ip
}

output "master_private_ip" {
  description = "Private IP address of the Kubernetes master node"
  value       = module.ec2_master.aws_instance.master.private_ip
}
