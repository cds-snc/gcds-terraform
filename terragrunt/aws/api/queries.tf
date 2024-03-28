resource "aws_cloudwatch_query_definition" "errors_query" {
  name = "GC Design System - Errors"

  log_group_names = [
    local.api_cloudwatch_log_group
  ]

  query_string = <<-QUERY
    fields @timestamp, @message, @logStream
    | filter @message like /(?i)ERROR/
    | sort @timestamp desc
    | limit 20
  QUERY
}

resource "aws_cloudwatch_query_definition" "warnings_query" {
  name = "GC Design System - Warnings"

  log_group_names = [
    local.api_cloudwatch_log_group
  ]

  query_string = <<-QUERY
    fields @timestamp, @message, @logStream
    | filter @message like /WARNING/
    | sort @timestamp desc
    | limit 20
  QUERY
}