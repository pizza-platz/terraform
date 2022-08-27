output "clusters" {
  value = {
    hawaiian = module.hawaiian_cluster
  }
}

output "services" {
  value = {
    hawaiian = module.hawaiian_services
  }
}

output "domain_name" {
  description = "Route53 zone for all clusters"
  value       = aws_route53_zone.this.name
}
