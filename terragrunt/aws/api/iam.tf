data "aws_iam_policy_document" "api_policies" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
    ]
    resources = [
      aws_ssm_parameter.gcds_api_config.arn
    ]
  }
}