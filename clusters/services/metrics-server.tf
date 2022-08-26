locals {
  metrics_server_namespace = "metrics-server"
}

resource "kubernetes_namespace" "metrics_server" {
  metadata {
    name = local.metrics_server_namespace
  }
}

resource "helm_release" "metrics_server" {
  depends_on = [
    kubernetes_namespace.metrics_server,
  ]

  name       = "metrics-server"
  namespace  = local.metrics_server_namespace
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.8.2"
}
