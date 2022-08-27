data "terraform_remote_state" "clusters" {
  backend = "s3"

  config = {
    profile = "default-admin"
    bucket  = "platz-tf-state"
    key     = "clusters.tfstate"
    region  = "us-east-1"
  }
}
