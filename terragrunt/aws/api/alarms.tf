resource "aws_cloudwatch_log_metric_filter" "gc_design_system_error" {
  name           = local.error_logged
  pattern        = "?ERROR ?Error"
  log_group_name = local.api_cloudwatch_log_group

  metric_transformation {
    name      = local.error_logged
    namespace = local.error_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "gc_design_system_error" {
  alarm_name          = "GC Design System Errors"
  alarm_description   = "Errors logged by the GC Design System"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  metric_name        = aws_cloudwatch_log_metric_filter.gc_design_system_error.metric_transformation[0].name
  namespace          = aws_cloudwatch_log_metric_filter.gc_design_system_error.metric_transformation[0].namespace
  period             = "60"
  evaluation_periods = "1"
  statistic          = "Sum"
  threshold          = var.error_threshold
  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_warning.arn]
  ok_actions    = [aws_sns_topic.cloudwatch_warning.arn]
}

resource "aws_cloudwatch_log_metric_filter" "gc_design_system_warning" {
  name           = local.warning_logged
  pattern        = "WARNING"
  log_group_name = local.api_cloudwatch_log_group

  metric_transformation {
    name      = local.warning_logged
    namespace = local.error_namespace
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "gc_design_system_warning" {
  alarm_name          = "GC Design System Warnings"
  alarm_description   = "Warnings logged by the GC Design System"
  comparison_operator = "GreaterThanOrEqualToThreshold"

  metric_name        = aws_cloudwatch_log_metric_filter.gc_design_system_warning.metric_transformation[0].name
  namespace          = aws_cloudwatch_log_metric_filter.gc_design_system_warning.metric_transformation[0].namespace
  period             = "60"
  evaluation_periods = "1"
  statistic          = "Sum"
  threshold          = var.warning_threshold
  treat_missing_data = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_warning.arn]
  ok_actions    = [aws_sns_topic.cloudwatch_warning.arn]
}