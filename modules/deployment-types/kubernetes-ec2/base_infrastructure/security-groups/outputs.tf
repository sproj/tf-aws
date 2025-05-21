output "node_sg_ids" {
  value = [aws_security_group.nodes.id]
}

output "master_sg_ids" {
  value = [aws_security_group.master.id]
}