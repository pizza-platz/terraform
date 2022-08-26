data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.num_azs)
  subnet_bits        = 4
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.cluster_name
  cidr = var.vpc_cidr

  azs            = local.availability_zones
  public_subnets = [for i in range(var.num_azs) : cidrsubnet(var.vpc_cidr, local.subnet_bits, i)]
}
