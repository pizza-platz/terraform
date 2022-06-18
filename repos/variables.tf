variable "repos" {
  description = "ECR repos to create"
  default = [
    "shop",
    "shop-charts",
  ]
}
