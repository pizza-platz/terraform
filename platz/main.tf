data "aws_ssm_parameter" "oidc_server_url" {
  name = "/platz/oidc/server-url"
}

data "aws_ssm_parameter" "oidc_client_id" {
  name = "/platz/oidc/client-id"
}

data "aws_ssm_parameter" "oidc_client_secret" {
  name = "/platz/oidc/client-secret"
}

module "platz" {
  source = "github.com/platzio/terraform-aws-platzio?ref=v0.4.6/modules/main"

  k8s_cluster_name = var.cluster_name
  chart_version    = var.chart_version
  use_chart_db     = false
  db_url_override  = local.db_url

  ingress = {
    host       = data.terraform_remote_state.clusters.outputs.domain_name
    class_name = "nginx"
    tls = {
      secret_name        = "tls-cert"
      create_certificate = true
      create_issuer      = true
      issuer_email       = "acme@${data.terraform_remote_state.clusters.outputs.domain_name}"
    }
  }

  oidc_ssm_params = {
    server_url    = data.aws_ssm_parameter.oidc_server_url.name
    client_id     = data.aws_ssm_parameter.oidc_client_id.name
    client_secret = data.aws_ssm_parameter.oidc_client_secret.name
  }

  chart_discovery = module.platz_chart_discovery

  k8s_agents = [
    data.terraform_remote_state.clusters.outputs.services[var.cluster_name].platz_k8s_agent_role,
  ]
}

module "platz_chart_discovery" {
  source = "github.com/platzio/terraform-aws-platzio?ref=v0.4.6/modules/chart-discovery"

  irsa_oidc_provider = data.terraform_remote_state.clusters.outputs.clusters[var.cluster_name].oidc_provider_host
  irsa_oidc_arn      = data.terraform_remote_state.clusters.outputs.clusters[var.cluster_name].oidc_provider_arn
}
