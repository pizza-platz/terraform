data "aws_iam_roles" "admins" {
  name_regex  = "AWSReservedSSO_AdministratorAccess_.*"
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
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
