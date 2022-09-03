locals {
  reflector_namespace       = "reflector"
  reflector_service_account = "reflector"
}

resource "kubernetes_namespace" "reflector" {
  metadata {
    name = local.reflector_namespace
  }
}

resource "helm_release" "reflector" {
  depends_on = [
    kubernetes_namespace.reflector,
  ]

  name       = "reflector"
  namespace  = local.reflector_namespace
  repository = "https://emberstack.github.io/helm-charts"
  chart      = "reflector"
  version    = "6.1.47"
}
