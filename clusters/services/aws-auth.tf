data "aws_iam_roles" "admins" {
  name_regex  = "AWSReservedSSO_AdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

module "platz_k8s_agent_role" {
  source = "github.com/platzio/terraform-aws-platzio?ref=v0.4.6/modules/k8s-agent-role"

  k8s_agent_name     = "default"
  irsa_oidc_provider = var.oidc_provider_host
  irsa_oidc_arn      = var.oidc_provider_arn
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    namespace = "kube-system"
    name      = "aws-auth"
  }

  force = true

  data = {
    mapRoles = yamlencode(
      concat(
        [
          for parts in [for arn in data.aws_iam_roles.admins.arns : split("/", arn)] :
          {
            rolearn  = format("%s/%s", parts[0], element(parts, length(parts) - 1))
            username = "Administrator:{{SessionName}}"
            groups   = ["system:masters"]
          }
        ],
        [
          {
            rolearn  = module.platz_k8s_agent_role.iam_role_arn
            username = "Administrator:Platz"
            groups   = ["system:masters"]
          }
        ],
        [
          {
            rolearn  = var.node_role_arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups = [
              "system:bootstrappers",
              "system:nodes",
            ]
          }
        ]
      )
    )
  }
}
