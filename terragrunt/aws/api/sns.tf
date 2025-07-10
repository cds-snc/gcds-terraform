#
# SNS: topic & subscription
#
resource "aws_sns_topic" "cloudwatch_warning" {
  name              = "gc-design-system-cloudwatch-alarms-warning"
  kms_master_key_id = aws_kms_key.sns_cloudwatch.id

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_sns_topic_subscription" "alert_warning" {
  topic_arn = aws_sns_topic.cloudwatch_warning.arn
  protocol  = "https"
  endpoint  = var.slack_webhook_url
}

# KMS Key for SNS CloudWatch topic
# This key is used to encrypt messages sent to the SNS topic for CloudWatch alarms.
resource "aws_kms_key" "sns_cloudwatch" {
  # checkov:skip=CKV_AWS_7: key rotation not required for CloudWatch SNS topic's messages
  description = "KMS key for CloudWatch SNS topic"
  policy      = data.aws_iam_policy_document.sns_cloudwatch.json
}

# IAM policy document for the KMS key used by SNS CloudWatch topic
data "aws_iam_policy_document" "sns_cloudwatch" {
  # checkov:skip=CKV_AWS_109: `resources = ["*"]` identifies the KMS key to which the key policy is attached
  # checkov:skip=CKV_AWS_111: `resources = ["*"]` identifies the KMS key to which the key policy is attached
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["kms:*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_id}:root"]
    }
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
    ]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }
  }
}