terraform {
  source = "../../../aws//website"
}

dependencies {
  paths = ["../route53", "../api"]
}

dependency "route53" {
  config_path = "../route53"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs = {
    hosted_zone_id_website_en = "Z001234567890ABCDEFGHIJ"
    hosted_zone_id_website_fr = "Z001234567890ABCDEFGHIJ"
  }
}

dependency "api" {
  config_path = "../api"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs = {
    function_url = "https://api.design-system.com"
  }
}

inputs = {
  hosted_zone_id_en = dependency.route53.outputs.hosted_zone_id_website_en
  hosted_zone_id_fr = dependency.route53.outputs.hosted_zone_id_website_fr
  api_function_url  = dependency.api.outputs.function_url
}

include {
  path = find_in_parent_folders()
}
