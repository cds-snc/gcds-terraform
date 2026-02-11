variable "gh_access_token" {
  type      = string
  sensitive = true
}

variable "api_function_url" {
  description = "The URL of the API lambda function"
  type        = string
  sensitive   = true
}