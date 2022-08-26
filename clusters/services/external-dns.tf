locals {
  external_dns_namespace       = "external-dns"
  external_dns_service_account = "external-dns"
}

resource "kubernetes_namespace" "external_dns" {
  metadata {
    name = local.external_dns_namespace
  }
}

resource "helm_release" "external_dns" {
  depends_on = [
    kubernetes_namespace.external_dns,
  ]

  name       = "external-dns"
  namespace  = local.external_dns_namespace
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = "1.11.0"

  values = [templatefile("${path.module}/external-dns-values.yaml", {
    service_account_name = local.external_dns_service_account
    role_arn             = aws_iam_role.external_dns.arn
    domain               = var.route53_zone_name
  })]
}

resource "aws_iam_role" "external_dns" {
  name               = "eks-${var.cluster_name}-external-dns"
  assume_role_policy = data.aws_iam_policy_document.external_dns_assume_role.json
}

data "aws_iam_policy_document" "external_dns_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_host}:sub"
      values   = ["system:serviceaccount:${local.external_dns_namespace}:${local.external_dns_service_account}"]
    }

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
  }
}

resource "aws_iam_policy" "external_dns" {
  name   = aws_iam_role.external_dns.name
  policy = data.aws_iam_policy_document.external_dns.json
}

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions = [
      "route53:ChangeResourceRecordSets",
    ]
    resources = [
      var.route53_zone_arn,
    ]
  }

  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}
