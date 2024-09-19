resource "aws_amplify_app" "design_system_fable_test_app" {
  name       = "GCDS Canadian Holidays"
  repository = "https://github.com/cds-snc/gcds-examples"

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
}


resource "aws_amplify_branch" "main_fable_test" {
  app_id      = aws_amplify_app.design_system_fable_test_app.id
  branch_name = "main"

  # Could be one of: PRODUCTION, BETA, DEVELOPMENT, EXPERIMENTAL, PULL_REQUEST
  stage = "PRODUCTION"

  display_name = "production"

  enable_pull_request_preview = true
}