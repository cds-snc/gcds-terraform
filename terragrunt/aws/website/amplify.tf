resource "aws_amplify_app" "design_system_docs" {
  name       = "Design System"
  repository = "https://github.com/cds-snc/gcds-docs"

  # Github personal access token
  # -- needed when setting up amplify or making changes
  access_token = var.gh_access_token

  build_spec = file("${path.module}/build_spec/amplify.yml")

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  # Redirect for english website
  custom_rule {
    source = var.domain_website_en
    status = "302"
    target = "${var.domain_website_en}/en"
  }

  # Redirect for french website
  custom_rule {
    source = var.domain_website_fr
    status = "302"
    target = "${var.domain_website_fr}/fr"
  }

  auto_branch_creation_config {
    # Enable auto build for the created branch.
    enable_auto_build             = true
    enable_pull_request_preview   = true
    pull_request_environment_name = "rc"
    stage                         = "PRODUCTION"
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.design_system_docs.id
  branch_name = "main"

  # Could be one of: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST
  stage = "PRODUCTION"

  display_name = "production"

  enable_pull_request_preview = false
}

resource "aws_amplify_domain_association" "design_system_en" {

  app_id      = aws_amplify_app.design_system_docs.id
  domain_name = var.domain_website_en

  wait_for_verification = false

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "www"
  }
}

resource "aws_amplify_domain_association" "design_system_fr" {

  app_id      = aws_amplify_app.design_system_docs.id
  domain_name = var.domain_website_fr

  wait_for_verification = false

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "www"
  }
}