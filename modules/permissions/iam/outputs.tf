output "creator_permissions" {
  value = local.iam_permissions.creator
}
output "manager_permissions" {
  value = local.iam_permissions.manager
}
output "reader_permissions" {
  value = local.iam_permissions.reader
}
