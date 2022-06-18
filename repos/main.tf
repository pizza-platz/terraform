resource "aws_ecr_repository" "this" {
  for_each             = toset(var.repos)
  name                 = each.value
  image_tag_mutability = "IMMUTABLE"
}
