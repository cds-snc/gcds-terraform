terraform {
  source = "../../../aws//cdn"
}

dependencies {
  paths = ["../route53"]
}

dependency "route53" {
  config_path = "../route53"

  mock_outputs_allowed_terraform_commands = ["init", "fmt", "validate", "plan", "show"]
  mock_outputs_merge_strategy_with_state  = "shallow"
  mock_outputs = {
    hosted_zone_id_cdn = "Z001234567890ABCDEFGHIJ"
  }
}

inputs = {
  hosted_zone_id                       = dependency.route53.outputs.hosted_zone_id_cdn
  platform_data_lake_raw_s3_bucket_arn = "arn:aws:s3:::cds-data-lake-raw-production"
}

include {
  path = find_in_parent_folders()
}
