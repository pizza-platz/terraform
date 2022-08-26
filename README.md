# Pizza Platz Terraform

This repo contains the Terraform config for [pizza.platz.io](https://pizza.platz.io).

## How to Deploy

Each directory contains a separate Terraform deployment, they each have to be applied separately and by the following order:

1. `repos`: Contains ECR repos
2. `clusters`: EKS clusters
4. `platz`: Platz installation
