output "creator_permissions" {
  value = local.ec2_permissions.creator
}
output "manager_permissions" {
  value = local.ec2_permissions.manager
}
output "reader_permissions" {
  value = local.ec2_permissions.reader
}
