variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "node_role_arn" {
  description = "AWS IAM role ARN for nodes"
  type        = string
}

variable "oidc_provider_host" {
  description = "IRSA OIDC provider without URL scheme"
  type        = string
}

variable "oidc_provider_arn" {
  description = "IRSA OIDC provider ARN"
  type        = string
}

variable "route53_zone_arn" {
  description = "Route53 zone ARN to run external-dns on"
  type        = string
}

variable "route53_zone_name" {
  description = "DNS zone name for external-dns"
  type        = string
}
