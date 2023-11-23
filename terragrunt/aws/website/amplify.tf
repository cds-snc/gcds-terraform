resource "aws_amplify_app" "design_system_docs_en" {
  name       = "Design System (EN)"
  repository = "https://github.com/cds-snc/gcds-docs"

  # Github personal access token
  # -- needed when setting up amplify or making changes
  access_token = var.gh_access_token

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
    target = "https://${var.domain_website_fr}/fr/<*>"
    status = "301"
  }

  # Redirect for the homepage
  custom_rule {
    source = "/"
    target = "/en/"
    status = "200"
  }
}

resource "aws_amplify_app" "design_system_docs_fr" {
  name       = "Design System (FR)"
  repository = "https://github.com/cds-snc/gcds-docs"

  # Github personal access token
  # -- needed when setting up amplify or making changes
  access_token = var.gh_access_token

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
    target = "https://${var.domain_website_en}/en/<*>"
    status = "301"
  }

  # Redirect for the homepage
  custom_rule {
    source = "/"
    target = "/fr/"
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
  enable_pull_request_preview = false
}

resource "aws_amplify_domain_association" "design_system_en" {
  app_id      = aws_amplify_app.design_system_docs_en.id
  domain_name = var.domain_website_en

  wait_for_verification = false

  sub_domain {
    branch_name = aws_amplify_branch.main_en.branch_name
    prefix      = ""
  }
}

resource "aws_amplify_domain_association" "design_system_fr" {
  app_id      = aws_amplify_app.design_system_docs_fr.id
  domain_name = var.domain_website_fr

  wait_for_verification = false

  sub_domain {
    branch_name = aws_amplify_branch.main_fr.branch_name
    prefix      = ""
  }
}