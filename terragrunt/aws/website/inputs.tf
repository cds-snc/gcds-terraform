variable "hosted_zone_id_en" {
  description = "The ID of the Route53 hosted zone to create the website's English DNS records in"
  type        = string
}

variable "hosted_zone_id_fr" {
  description = "The ID of the Route53 hosted zone to create the website's French DNS records in"
  type        = string
}

variable "gh_access_token" {
  type      = string
  sensitive = true
}

variable "api_function_url" {
  description = "The URL of the API lambda function"
  type        = string
  sensitive   = true
}