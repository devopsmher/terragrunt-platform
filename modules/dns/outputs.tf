output "zone_id" {
  description = "Hosted zone ID."
  value       = aws_route53_zone.this.zone_id
}

output "zone_name" {
  description = "Hosted zone name."
  value       = aws_route53_zone.this.name
}

output "name_servers" {
  description = "Name servers to delegate the zone from the parent domain."
  value       = aws_route53_zone.this.name_servers
}
