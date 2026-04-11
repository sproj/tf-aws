output "creator_permissions" {
  value = local.ssm_permissions.creator
}
output "manager_permissions" {
  value = local.ssm_permissions.manager
}
output "reader_permissions" {
  value = local.ssm_permissions.reader
}
