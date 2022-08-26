terraform {
  backend "s3" {
    profile = "default-admin"
    bucket  = "platz-tf-state"
    key     = "repos.tfstate"
    region  = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "default-admin"
}
