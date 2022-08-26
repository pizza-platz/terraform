locals {
  cert_manager_namespace = "cert-manager"
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = local.cert_manager_namespace
  }
}

resource "helm_release" "cert_manager" {
  depends_on = [
    kubernetes_namespace.cert_manager,
  ]

  name       = "cert-manager"
  namespace  = local.cert_manager_namespace
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.9.1"

  set {
    name  = "installCRDs"
    value = "true"
  }
}
