resource "aws_amplify_app" "design_system_docs_en" {
  name       = "Design System (EN)"
  repository = "https://github.com/cds-snc/gcds-docs"

  # Github personal access token
  # -- needed when setting up amplify or making changes
  access_token = var.gh_access_token

  # Legacy Eleventy apps: already linked to GitHub. Don't push a rotated
  # token or rule changes to them while the Astro app is being stood up.
  lifecycle {
    ignore_changes = [access_token, custom_rule]
  }

  build_spec = file("${path.module}/build_spec/amplify.yml")

  # 404 redirects
  custom_rule {
    source = "/<*>"
    target = "/404"
    status = "404"
  }

  # Redirect for the french website
  custom_rule {
    source = "/fr/<*>"
    target = "https://${var.ca_domain_website_fr}/fr/<*>"
    status = "301"
  }

  # Redirect for the homepage
  custom_rule {
    source = "/"
    target = "/en/"
    status = "200"
  }

  # Redirect for the get started pages
  custom_rule {
    source = "/en/get-started/<*>"
    target = "/en/start-to-use/<*>"
    status = "301"
  }

  # Redirect for the API contact form submission
  custom_rule {
    source = "/api/submission"
    target = "${var.api_function_url}submission"
    status = "200"
  }
}

resource "aws_amplify_app" "design_system_docs_fr" {
  name       = "Design System (FR)"
  repository = "https://github.com/cds-snc/gcds-docs"

  # Github personal access token
  # -- needed when setting up amplify or making changes
  access_token = var.gh_access_token

  # Legacy Eleventy apps: already linked to GitHub. Don't push a rotated
  # token or rule changes to them while the Astro app is being stood up.
  lifecycle {
    ignore_changes = [access_token, custom_rule]
  }

  build_spec = file("${path.module}/build_spec/amplify.yml")

  # 404 redirects
  custom_rule {
    source = "/<*>"
    target = "/404"
    status = "404"
  }

  # Redirect for english website
  custom_rule {
    source = "/en/<*>"
    target = "https://${var.ca_domain_website_en}/en/<*>"
    status = "301"
  }

  # Redirect for the homepage
  custom_rule {
    source = "/"
    target = "/fr/"
    status = "200"
  }

  # Redirect for the API contact form submission
  custom_rule {
    source = "/api/submission"
    target = "${var.api_function_url}submission"
    status = "200"
  }
}


resource "aws_amplify_branch" "main_en" {
  app_id      = aws_amplify_app.design_system_docs_en.id
  branch_name = "main"

  # Could be one of: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST
  stage = "PRODUCTION"

  display_name = "production"

  # We only need one preview environment since it contains both english and french content
  enable_pull_request_preview = true
}

resource "aws_amplify_branch" "main_fr" {
  app_id      = aws_amplify_app.design_system_docs_fr.id
  branch_name = "main"

  # Could be one of: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST
  stage = "PRODUCTION"

  display_name = "production"

  # We only need one preview environment since it contains both english and french content
  enable_pull_request_preview = true
}

# Custom domain (design-system.canada.ca) for the english amplify app
resource "aws_amplify_domain_association" "gcds_en" {
  app_id      = aws_amplify_app.design_system_docs_en.id
  domain_name = var.ca_domain_website_en

  wait_for_verification = false

  sub_domain {
    branch_name = aws_amplify_branch.main_en.branch_name
    prefix      = ""
  }
}

# Custom domain (systeme-design.canada.ca) for the french amplify app
resource "aws_amplify_domain_association" "gcds_fr" {
  app_id      = aws_amplify_app.design_system_docs_fr.id
  domain_name = var.ca_domain_website_fr

  wait_for_verification = false

  sub_domain {
    branch_name = aws_amplify_branch.main_fr.branch_name
    prefix      = ""
  }
}

###############################################################################
# Astro documentation site (Amplify Gen 2)
#
# Unlike the Eleventy setup above, this is a SINGLE app serving both languages.
# Both custom domains point at the same branch of the same app.
#
# Amplify evaluates custom rules per app, not per domain -- `condition` on a
# custom_rule only matches country codes, never the Host header. Per-domain
# behaviour (design-system.canada.ca -> /en/, systeme-design.canada.ca -> /fr/)
# is therefore handled by docs/src/pages/index.astro, which reads
# location.hostname and redirects. Once the app moves to WEB_COMPUTE, that page
# is replaced by Astro middleware reading the Host header server-side.
###############################################################################

locals {
  # Flipping var.astro_domain_stage to "canada_ca" is the production cutover.
  astro_on_canada_ca = var.astro_domain_stage == "canada_ca"

  # When in alpha stage, use canada.ca domains with a staging prefix (e.g., astro-staging).
  # When in canada_ca stage, use the apex (no prefix).
  astro_domain_en = var.ca_domain_website_en
  astro_domain_fr = var.ca_domain_website_fr

  # Prefix: empty for production, "astro-staging" for alpha stage
  astro_subdomain_prefix = local.astro_on_canada_ca ? "" : var.astro_alpha_subdomain_prefix
}

resource "aws_amplify_app" "design_system_docs_astro" {
  name       = "Design System (Astro)"
  repository = "https://github.com/cds-snc/gcds-docs"

  # Github personal access token
  # -- needed when setting up amplify or making changes
  access_token = var.gh_access_token

  # WEB = static hosting of docs/dist. Switch to WEB_COMPUTE for SSR.
  platform = var.astro_platform

  build_spec = file("${path.module}/build_spec/${var.astro_build_spec}")

  environment_variables = {
    # No AMPLIFY_MONOREPO_APP_ROOT on purpose -- see build_spec/amplify_astro.yml.

    # Always deploy the full artifact set. Diff deploys are unreliable when the
    # output directory sits below the repo root.
    AMPLIFY_DIFF_DEPLOY = "false"

    # Amazon Linux 2023 image, which ships a Node version Astro supports.
    _CUSTOM_IMAGE = "amplify:al2023"
  }

  # 404 redirects
  custom_rule {
    source = "/<*>"
    target = "/404"
    status = "404"
  }

  # Redirect for the get started pages (carried over from the Eleventy site)
  custom_rule {
    source = "/en/get-started/<*>"
    target = "/en/start-to-use/<*>"
    status = "301"
  }

  # Redirect for the API contact form submission
  custom_rule {
    source = "/api/submission"
    target = "${var.api_function_url}submission"
    status = "200"
  }

  # NOTE: there is deliberately no rule for "/". The Astro index page performs the
  # hostname check described above. If you ever want the Eleventy behaviour of
  # sending every bare root to English instead, uncomment the following -- but be
  # aware it takes precedence over the Astro page and breaks the French domain.
  #
  # custom_rule {
  #   source = "/"
  #   target = "/en/"
  #   status = "200"
  # }

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_amplify_branch" "main_astro" {
  app_id      = aws_amplify_app.design_system_docs_astro.id
  branch_name = var.astro_branch_name

  # Could be one of: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST
  stage = "PRODUCTION"

  display_name = "production"

  # One preview environment covers both languages, since this app serves both.
  enable_pull_request_preview = true

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

# English domain for the Astro app.
# alpha stage     -> astro-staging.design-system.canada.ca
# canada_ca stage -> design-system.canada.ca
resource "aws_amplify_domain_association" "astro_en" {
  app_id      = aws_amplify_app.design_system_docs_astro.id
  domain_name = local.astro_domain_en

  wait_for_verification = false

  sub_domain {
    branch_name = aws_amplify_branch.main_astro.branch_name
    prefix      = local.astro_subdomain_prefix
  }
}

# French domain for the Astro app.
# alpha stage     -> astro-staging.systeme-design.canada.ca
# canada_ca stage -> systeme-design.canada.ca
resource "aws_amplify_domain_association" "astro_fr" {
  app_id      = aws_amplify_app.design_system_docs_astro.id
  domain_name = local.astro_domain_fr

  wait_for_verification = false

  sub_domain {
    branch_name = aws_amplify_branch.main_astro.branch_name
    prefix      = local.astro_subdomain_prefix
  }
}
