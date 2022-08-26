module "hawaiian_cluster" {
  source = "./cluster"

  cluster_name = "hawaiian"
}

module "hawaiian_services" {
  source = "./services"

  cluster_name       = module.hawaiian_cluster.cluster_name
  node_role_arn      = module.hawaiian_cluster.node_role_arn
  oidc_provider_host = module.hawaiian_cluster.oidc_provider_host
  oidc_provider_arn  = module.hawaiian_cluster.oidc_provider_arn
  route53_zone_arn   = aws_route53_zone.this.arn
  route53_zone_name  = aws_route53_zone.this.name
}
