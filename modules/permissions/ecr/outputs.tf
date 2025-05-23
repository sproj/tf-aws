output "creator_permissions" {
  value = local.ecr_permissions.creator
}
output "manager_permissions" {
  value = local.ecr_permissions.manager
}
output "reader_permissions" {
  value = local.ecr_permissions.reader
}
