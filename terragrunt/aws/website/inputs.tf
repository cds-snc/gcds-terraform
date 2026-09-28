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

variable "astro_app_root" {
  description = "Path to the Astro project inside the gcds-docs repo. Must match `appRoot` in the build spec."
  type        = string
  default     = "docs"
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

variable "astro_domain_stage" {
  description = <<-EOT
    Which domains the Astro app is served from.
      alpha     - staging subdomains under canada.ca domains (see astro_alpha_subdomain_prefix)
      canada_ca - the production design-system.canada.ca / systeme-design.canada.ca domains

    Amplify will not let two apps claim the same domain, so "canada_ca" is only
    valid once the Eleventy domain associations (aws_amplify_domain_association.gcds_en
    and .gcds_fr in amplify.tf) have been removed in the same change.
  EOT
  type        = string
  default     = "alpha"

  validation {
    condition     = contains(["alpha", "canada_ca"], var.astro_domain_stage)
    error_message = "astro_domain_stage must be either alpha or canada_ca."
  }
}

variable "astro_alpha_subdomain_prefix" {
  description = <<-EOT
    Subdomain prefix used while astro_domain_stage is "alpha", producing e.g.
    astro-staging.design-system.canada.ca. Ignored when astro_domain_stage is "canada_ca".
  EOT
  type        = string
  default     = "astro-staging"
}
