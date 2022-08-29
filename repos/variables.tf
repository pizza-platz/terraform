variable "repos" {
  description = "ECR repos to create"
  default = [
    "agency",
    "agency-chart",
    "bank",
    "bank-chart",
    "customer",
    "customer-chart",
    "farm",
    "farm-chart",
    "shop",
    "shop-chart",
    "supplier",
    "supplier-chart",
  ]
}

variable "github_organization" {
  description = "GitHub organization allowed to push images to ECR"
  default     = "pizza-platz"
}
