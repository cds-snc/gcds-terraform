output "cdn_cloudfront_log_bucket" {
  description = "The S3 bucket where CloudFront logs are stored"
  value       = module.cloudfront_logs.s3_bucket_domain_name
}