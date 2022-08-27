variable "repos" {
  description = "ECR repos to create"
  default = [
    "shop",
    "shop-charts",
  ]
}

variable "github_organization" {
  description = "GitHub organization allowed to push images to ECR"
  default     = "pizza-platz"
}
