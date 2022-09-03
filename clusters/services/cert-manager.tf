locals {
  cert_manager_namespace       = "cert-manager"
  cert_manager_service_account = "cert-manager"
  wildcard_cert_issuer         = "default"
  wildcard_cert_name           = "tls-wildcard"
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

  set {
    name  = "serviceAccount.name"
    value = local.cert_manager_service_account
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager.arn
  }
}

resource "aws_iam_role" "cert_manager" {
  name               = "eks-${var.cluster_name}-cert-manager"
  assume_role_policy = data.aws_iam_policy_document.cert_manager_assume_role.json
}

data "aws_iam_policy_document" "cert_manager_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_host}:sub"
      values   = ["system:serviceaccount:${local.cert_manager_namespace}:${local.cert_manager_service_account}"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
  }
}

resource "aws_iam_policy" "cert_manager" {
  name   = aws_iam_role.cert_manager.name
  policy = data.aws_iam_policy_document.cert_manager.json
}

data "aws_iam_policy_document" "cert_manager" {
  statement {
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets"
    ]
    resources = [data.aws_route53_zone.this.arn]
  }
}

resource "aws_iam_role_policy_attachment" "cert_manager" {
  role       = aws_iam_role.cert_manager.name
  policy_arn = aws_iam_policy.cert_manager.arn
}

resource "kubernetes_manifest" "wildcard_issuer" {
  depends_on = [
    helm_release.cert_manager,
  ]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = local.wildcard_cert_issuer
    }

    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = "acme@${var.route53_zone_name}"
        privateKeySecretRef = {
          name = local.wildcard_cert_name
        }
        solvers = [
          {
            selector = {
              dnsZones = [data.aws_route53_zone.this.name]
            }
            dns01 = {
              route53 = {
                region       = data.aws_region.current.name
                hostedZoneID = data.aws_route53_zone.this.zone_id
              }
            }
          }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "wildcard_cert" {
  depends_on = [
    kubernetes_manifest.wildcard_issuer,
  ]

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      namespace = "default"
      name      = local.wildcard_cert_name
    }

    spec = {
      secretName = local.wildcard_cert_name
      subject = {
        organizations = ["*.${var.route53_zone_name}"]
      }
      commonName = "*.${var.route53_zone_name}"
      privateKey = {

        algorithm = "ECDSA"
        size      = 256
      }
      dnsNames = ["*.${var.route53_zone_name}"]
      issuerRef = {
        name  = local.wildcard_cert_issuer
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
      secretTemplate = {
        annotations = {
          "reflector.v1.k8s.emberstack.com/reflection-allowed"            = "true"
          "reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces" = ""
          "reflector.v1.k8s.emberstack.com/reflection-auto-enabled"       = "true"
          "reflector.v1.k8s.emberstack.com/reflection-auto-namespaces"    = ""
        }
      }
    }
  }
}
