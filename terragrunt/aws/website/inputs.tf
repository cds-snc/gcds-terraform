variable "gh_access_token" {
  type      = string
  sensitive = true
}

variable "api_function_url" {
  description = "The URL of the API lambda function"
  type        = string
  sensitive   = true
}

###############################################################################
# Astro documentation site (Amplify Gen 2)
#
# Every variable below has a default, so nothing new has to be supplied by
# terragrunt. Each one exists to make a future change a variable flip rather
# than a code edit.
###############################################################################

variable "astro_branch_name" {
  description = "Branch of cds-snc/gcds-docs that the Astro app builds from."
  type        = string
  default     = "main"
}

variable "astro_build_spec" {
  description = "Build spec file under build_spec/ used by the Astro app. Swap for an SSR build spec when moving off static hosting."
  type        = string
  default     = "amplify_astro.yml"
}

variable "astro_platform" {
  description = <<-EOT
    Amplify hosting platform for the Astro app.
      WEB         - static hosting, serves the prerendered docs/dist output (current)
      WEB_COMPUTE - SSR hosting, required once Astro uses the AWS Amplify adapter
    Changing this also requires swapping var.astro_build_spec.
  EOT
  type        = string
  default     = "WEB"

  validation {
    condition     = contains(["WEB", "WEB_COMPUTE"], var.astro_platform)
    error_message = "astro_platform must be either WEB or WEB_COMPUTE."
  }
}

variable "astro_domain" {
  description = <<-EOT
    Which domains the Astro app is served from.
      alpha     - staging subdomains under canada.ca domains (see astro_alpha_subdomain_prefix)
      canada_ca - the production design-system.canada.ca / systeme-design.canada.ca domains

  EOT
  type        = string
  default     = "canada_ca"

  validation {
    condition     = contains(["alpha", "canada_ca"], var.astro_domain)
    error_message = "astro_domain must be either alpha or canada_ca."
  }
}

variable "astro_alpha_subdomain_prefix" {
  description = <<-EOT
    Subdomain prefix used while astro_domain is "alpha", producing e.g.
    astro-staging.design-system.canada.ca. Ignored when astro_domain is "canada_ca".
  EOT
  type        = string
  default     = "astro-staging"
}
