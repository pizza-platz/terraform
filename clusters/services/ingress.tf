locals {
  ingress_namespace = "ingress-nginx"
}

resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = local.ingress_namespace
  }
}

resource "helm_release" "ingress_nginx" {
  depends_on = [
    kubernetes_namespace.ingress_nginx,
  ]

  name       = "ingress-nginx"
  namespace  = local.ingress_namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.2.3"
}
