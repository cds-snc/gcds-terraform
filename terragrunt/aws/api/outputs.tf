output "function_url" {
  description = "The URL of the Lambda function"
  value       = aws_lambda_function_url.api.function_url
  sensitive   = true
}