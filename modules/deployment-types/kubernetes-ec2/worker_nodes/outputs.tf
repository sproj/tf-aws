output "asg_name" {
  value = module.ec2_nodes.aws_autoscaling_group.nodes.name
}
