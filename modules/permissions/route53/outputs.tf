output "creator_permissions" {
  value = local.route53_permissions.creator
}
output "manager_permissions" {
  value = local.route53_permissions.manager
}
output "reader_permissions" {
  value = local.route53_permissions.reader
}
