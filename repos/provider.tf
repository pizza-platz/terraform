terraform {
  cloud {
    organization = "platz"

    workspaces {
      name = "repos"
    }
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