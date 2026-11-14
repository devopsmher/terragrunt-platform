# DNS: the environment owns its own public zone.
# The parent domain lives in a separate DNS account; the platform team adds an NS record there
# with the name_servers output (see docs/quick-start.md). After that the team manages its records
# itself, for example with external-dns in the cluster.

resource "aws_route53_zone" "this" {
  name    = var.zone_name
  comment = "Managed by Terragrunt"
  tags    = var.tags
}
