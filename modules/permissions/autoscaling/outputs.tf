output "creator_permissions" {
  value = local.autoscaling_permissions.creator
}
output "manager_permissions" {
  value = local.autoscaling_permissions.manager
}
output "reader_permissions" {
  value = local.autoscaling_permissions.reader
}
