variable "cluster_name" {
  description = "EKS cluster name to install Platz on"
  default     = "hawaiian"
}

variable "chart_version" {
  description = "Platz chart version to install"
  default     = "v0.4.7-beta.1"
}

variable "name_prefix" {
  description = "Prefix to use for named resources"
  default     = "pizza-platz"
}

variable "admin_emails" {
  description = "Email addresses to add as first admins"
  type        = list(string)

  validation {
    condition     = length(var.admin_emails) >= 1
    error_message = "Please specify at least one admin email"
  }
}

variable "oidc_ssm_params" {
  description = "SSM parameter names for configuring OIDC authentication"
  type = object({
    server_url    = string
    client_id     = string
    client_secret = string
  })
  default = {
    server_url    = "/platz/oidc/server-url"
    client_id     = "/platz/oidc/client-id"
    client_secret = "/platz/oidc/client-secret"
  }
}
