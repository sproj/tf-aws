output "worker_arn" {
  description = "Worker ASG name"
  value = module.worker_nodes.worker_asg_arn
}

output "worker_name" {
  description = "Name of the worker node ASG"
  value = module.worker_nodes.worker_asg_name
}

