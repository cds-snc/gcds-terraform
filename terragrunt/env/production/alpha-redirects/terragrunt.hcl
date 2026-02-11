terraform {
  source = "../../../aws//alpha-redirects"
}

dependencies {
  paths = ["../route53"]
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

inputs = {
  hosted_zone_id_en = dependency.route53.outputs.hosted_zone_id_website_en
  hosted_zone_id_fr = dependency.route53.outputs.hosted_zone_id_website_fr
  cdn_cloudfront_log_bucket = dependency.cdn.outputs.cdn_cloudfront_log_bucket
}

include {
  path = find_in_parent_folders()
}
