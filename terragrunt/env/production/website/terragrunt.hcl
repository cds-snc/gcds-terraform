terraform {
  source = "../../../aws//website"
}

dependencies {
  paths = ["../route53"]
}

dependency "route53" {
  config_path = "../route53"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs = {
    hosted_zone_id_en = "Z001234567890ABCDEFGHIJ"
    hosted_zone_id_fr = "Z001234567890ABCDEFGHIJ"
  }
}

inputs = {
  hosted_zone_id_en = dependency.route53.outputs.hosted_zone_id_en
  hosted_zone_id_fr = dependency.route53.outputs.hosted_zone_id_fr
}

include {
  path = find_in_parent_folders()
}
