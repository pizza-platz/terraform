data "aws_ssm_parameter" "oidc_server_url" {
  name = var.oidc_ssm_params.server_url
}

data "aws_ssm_parameter" "oidc_client_id" {
  name = var.oidc_ssm_params.client_id
}

data "aws_ssm_parameter" "oidc_client_secret" {
  name = var.oidc_ssm_params.client_secret
}

data "cloudinit_config" "this" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/init.sh", {
      chart_version             = var.chart_version
      backend_version_override  = var.backend_version_override
      frontend_version_override = var.frontend_version_override

      domain_name  = var.domain_name
      admin_emails = var.admin_emails

      oidc_secret_name   = "oidc-config"
      oidc_server_url    = data.aws_ssm_parameter.oidc_server_url.value
      oidc_client_id     = data.aws_ssm_parameter.oidc_client_id.value
      oidc_client_secret = data.aws_ssm_parameter.oidc_client_secret.value

      db_endpoint = aws_db_instance.this.endpoint
      db_name     = aws_db_instance.this.db_name
      db_username = aws_db_instance.this.username
      db_password = random_password.db.result
    })
  }
}
