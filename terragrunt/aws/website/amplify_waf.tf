# WAF ACL for Design System Documentation (EN)
resource "aws_wafv2_web_acl" "amplify_docs" {
  provider = aws.core_services_us_east_1
  name     = "waf-${var.product_name}-amplify-docs-${var.env}"
  scope    = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # AWS Managed Rules - Common Rule Set (common vulnerabilities and bad bot protection)
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.product_name}-amplify-docs-common-rules"
      sampled_requests_enabled   = true
    }
  }

  # AWS managed bad input protections (includes Log4j-style payload detection)
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.product_name}-amplify-docs-known-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  # Rate Limiting Rule (only POST to /api/submission)
  rule {
    name     = "RateLimitRule"
    priority = 2

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"

        scope_down_statement {
          and_statement {
            statement {
              regex_match_statement {
                field_to_match {
                  uri_path {}
                }
                regex_string = "^/api/submission(/.*)?$"
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }

            statement {
              regex_match_statement {
                field_to_match {
                  method {}
                }
                regex_string = "^post$"
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.product_name}-amplify-docs-rate-limit"
      sampled_requests_enabled   = true
    }
  }

  # Block large requests to prevent abuse and DoS attacks
  rule {
    name     = "BlockLargeRequests"
    priority = 3

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        field_to_match {
          body {
            oversize_handling = "MATCH"
          }
        }
        comparison_operator = "GT"
        size                = 20480 # 20 KB
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.product_name}-amplify-docs-block-large-requests"
      sampled_requests_enabled   = true
    }
  }

  # Only allow POST on /api/submission
  rule {
    name     = "SubmissionMethodRestriction"
    priority = 4

    action {
      block {}
    }

    statement {
      and_statement {
        statement {
          regex_match_statement {
            regex_string = "^/api/submission(/.*)?$"
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
          }
        }

        statement {
          not_statement {
            statement {
              byte_match_statement {
                positional_constraint = "EXACTLY"
                search_string         = "post"
                field_to_match {
                  method {}
                }
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.product_name}-amplify-docs-submission-method-restriction"
      sampled_requests_enabled   = true
    }
  }

  # API Endpoint Protection - Whitelist known good paths (/api/submission) and block everything else under /api/
  rule {
    name     = "APIEndpointProtection"
    priority = 5

    action {
      block {
        custom_response {
          response_code = 403
        }
      }
    }

    statement {
      and_statement {
        statement {
          byte_match_statement {
            positional_constraint = "STARTS_WITH"
            field_to_match {
              uri_path {}
            }
            search_string = "/api/"
            text_transformation {
              priority = 0
              type     = "LOWERCASE"
            }
          }
        }

        statement {
          not_statement {
            statement {
              regex_match_statement {
                regex_string = "^/api/submission(/.*)?$"
                field_to_match {
                  uri_path {}
                }
                text_transformation {
                  priority = 0
                  type     = "LOWERCASE"
                }
              }
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.product_name}-amplify-docs-api-endpoint-protection"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.product_name}-amplify-docs"
    sampled_requests_enabled   = true
  }

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

# Associate WAF ACL with Amplify EN app
resource "aws_wafv2_web_acl_association" "amplify_en" {
  provider     = aws.core_services_us_east_1
  resource_arn = aws_amplify_app.design_system_docs_en.arn
  web_acl_arn  = aws_wafv2_web_acl.amplify_docs.arn
}

# Associate the same WAF ACL with Amplify FR app
resource "aws_wafv2_web_acl_association" "amplify_fr" {
  provider     = aws.core_services_us_east_1
  resource_arn = aws_amplify_app.design_system_docs_fr.arn
  web_acl_arn  = aws_wafv2_web_acl.amplify_docs.arn
}
