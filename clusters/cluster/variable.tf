variable "num_azs" {
  description = "How many AZs to create each VPC in"
  default     = 3
}

variable "vpc_cidr" {
  description = "VPC address range"
  default     = "10.0.0.0/16"
}

variable "cluster_name" {
  description = "EKS cluster name, also a prefix to other resources such as IAM roles"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to install"
  default     = "1.23"
}
