variable "api_config" {
  description = "The API environment variables that are written to a .env read by the Lambda function."
  type        = string
  sensitive   = true
}

variable "error_threshold" {
  description = "CloudWatch alarm threshold for the GC Design System ERROR logs"
  type        = string
  default     = "1"
}

variable "warning_threshold" {
  description = "CloudWatch alarm threshold for the GC Design System WARNING logs"
  type        = string
  default     = "10"
}

variable "slack_webhook_url" {
  description = "The URL of the Slack webhook."
  type        = string
  sensitive   = true
}