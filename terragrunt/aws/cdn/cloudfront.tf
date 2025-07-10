resource "aws_cloudfront_origin_access_identity" "cdn" {
  comment = "CloudFront CDN for ${var.product_name}-${var.env}"
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled     = true
  aliases     = [var.domain_cdn]
  price_class = "PriceClass_All"

  origin {
    domain_name = module.cdn_origin.s3_bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cdn.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    cache_policy_id            = local.cloudfront_cache_policy_optimized
    origin_request_policy_id   = local.cloudfront_origin_request_policy_cors_s3origin
    response_headers_policy_id = local.cloudfront_response_headers_policy_cors_preflight
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    bucket = module.cloudfront_logs.s3_bucket_domain_name
    prefix = "cloudfront-logs/"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cdn_certificate_validation.certificate_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

# Bucket to store cloudfront logscheck "name" {
module "cloudfront_logs" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v9.4.4"
  bucket_name       = "${var.product_name}-${var.env}-cdn-logs"
  billing_tag_value = var.billing_code

}

# Bucket policy to allow CloudFront to write logs
resource "aws_s3_bucket_policy" "cloudfront_logs_policy" {
  bucket = module.cloudfront_logs.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${module.cloudfront_logs.s3_bucket_id}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })

}

# Set the bucket ownership controls of the log bucket to ensure that CloudFront can write logs
resource "aws_s3_bucket_ownership_controls" "cloudfront_logs_ownership_controls" {
  bucket = module.cloudfront_logs.s3_bucket_id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
  depends_on = [module.cloudfront_logs]
}