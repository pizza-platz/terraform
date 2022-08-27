output "github_actions_iam_role_arn" {
  description = "IAM role ARN to use with GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}
