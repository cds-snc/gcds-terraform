variable "hosted_zone_id" {
  description = "The hosted zone ID for the CDN DNS records"
  type        = string
}

variable "platform_data_lake_raw_s3_bucket_arn" {
  description = "The ARN of the S3 bucket for the Platform Data Lake raw storage"
  type        = string
}