output "creator_permissions" {
  value = local.elasticloadbalancing_permissions.creator
}
output "manager_permissions" {
  value = local.elasticloadbalancing_permissions.manager
}
output "reader_permissions" {
  value = local.elasticloadbalancing_permissions.reader
}
