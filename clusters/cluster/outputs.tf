output "vpc_id" {
  description = "VPC ID of the EKS cluster"
  value       = module.vpc.vpc_id
}

output "vpc_public_subnets" {
  description = "VPC public subnet IDs"
  value       = module.vpc.public_subnets
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = var.cluster_name
}

output "node_role_arn" {
  description = "AWS IAM role ARN for nodes"
  value       = aws_iam_role.node.arn
}

output "nodes_security_group_id" {
  description = "Security group ID for intra-node traffic"
  value       = aws_security_group.nodes.id
}

output "oidc_provider_host" {
  description = "IRSA OIDC provider without URL scheme"
  value       = local.oidc_provider_host
}

output "oidc_provider_arn" {
  description = "IRSA OIDC provider ARN"
  value       = local.oidc_provider_arn
}
