output "cluster_name" {
  description = "EKS cluster name"
  value       = var.cluster_name
}

output "node_role_arn" {
  description = "AWS IAM role ARN for nodes"
  value       = aws_iam_role.node.arn
}

output "oidc_provider_host" {
  description = "IRSA OIDC provider without URL scheme"
  value       = local.oidc_provider_host
}

output "oidc_provider_arn" {
  description = "IRSA OIDC provider ARN"
  value       = local.oidc_provider_arn
}
