terraform {
  backend "s3" {
    profile = "default-admin"
    bucket  = "platz-tf-state"
    key     = "clusters.tfstate"
    region  = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.11.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default-admin"
}
