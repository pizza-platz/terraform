//---------//
// VPC CNI //
//---------//

data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "vpc_cni" {
  depends_on = [aws_eks_cluster.this]

  cluster_name             = var.cluster_name
  addon_name               = "vpc-cni"
  addon_version            = data.aws_eks_addon_version.vpc_cni.version
  service_account_role_arn = aws_iam_role.vpc_cni.arn
  resolve_conflicts        = "OVERWRITE"
}

resource "aws_iam_role" "vpc_cni" {
  assume_role_policy = data.aws_iam_policy_document.vpc_cni_assume_role.json
  name               = "eks-${var.cluster_name}-vpc-cni-role"
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc_cni.name
}

data "aws_iam_policy_document" "vpc_cni_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_host}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }
  }
}

//---------//
// CoreDNS //
//---------//

data "aws_eks_addon_version" "core_dns" {
  addon_name         = "coredns"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "core_dns" {
  depends_on = [aws_eks_cluster.this]

  cluster_name      = var.cluster_name
  addon_name        = "coredns"
  addon_version     = data.aws_eks_addon_version.core_dns.version
  resolve_conflicts = "OVERWRITE"
}

//------------//
// kube-proxy //
//------------//

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.kubernetes_version
  most_recent        = true
}

resource "aws_eks_addon" "kube_proxy" {
  depends_on = [aws_eks_cluster.this]

  cluster_name      = var.cluster_name
  addon_name        = "kube-proxy"
  addon_version     = data.aws_eks_addon_version.kube_proxy.version
  resolve_conflicts = "OVERWRITE"
}
