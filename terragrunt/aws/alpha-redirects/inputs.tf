variable "hosted_zone_id_en" {
  description = "The ID of the (Alpha) Route53 hosted zone to create DNS records for the redirects"
  type        = string
}

variable "hosted_zone_id_fr" {
  description = "The ID of the (Alpha) Route53 hosted zone to create DNS records for the redirects"
  type        = string
}

variable "cdn_cloudfront_log_bucket" {
  description = "The S3 bucket where CloudFront logs are stored"
  type        = string
}