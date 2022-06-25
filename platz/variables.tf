variable "domain_name" {
  description = "Domain name where Platz will be served from"
  default     = "pizza.platz.io"
}

variable "chart_version" {
  description = "Platz chart version to install"
  type        = string
}

variable "backend_version_override" {
  description = "Specify a backend image tag to override the value in the chart"
  default     = null
}

variable "frontend_version_override" {
  description = "Specify a frontend image tag to override the value in the chart"
  default     = null
}

variable "name_prefix" {
  description = "Prefix to use for named resources"
  default     = "pizza-platz"
}

variable "instance_type" {
  description = "EC2 instance type to run on"
  default     = "t3.micro"
}

variable "num_azs" {
  description = "How many AZs to create the VPC and ASG in"
  default     = 3
}

variable "vpc_cidr" {
  description = "VPC address range"
  default     = "10.0.0.0/16"
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
