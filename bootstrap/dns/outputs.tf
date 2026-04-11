output "zone_id" {
  description = "Zone id of the created hosted zone"
  value       = aws_route53_zone.jonesalan404_dev.zone_id
}

output "name_servers" {
  description = "Name servers of the created hosted zone"
  value       = aws_route53_zone.jonesalan404_dev.name_servers
}
