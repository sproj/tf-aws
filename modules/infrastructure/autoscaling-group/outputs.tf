output "asg_name" {
  value = aws_autoscaling_group.nodes.name
}

output "asg_arn" {
  value = aws_autoscaling_group.nodes.arn
}
