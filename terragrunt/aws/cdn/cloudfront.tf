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
    bucket = aws_s3_bucket.cloudfront_logs.bucket_domain_name
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
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "design-system-cloudfront-logs-bucket"
}

# Bucket policy to allow CloudFront to write logs
resource "aws_s3_bucket_policy" "cloudfront_logs_policy" {
  bucket = aws_s3_bucket.cloudfront_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.cloudfront_logs.id}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.cdn.arn
          }
        }
      }
    ]
  })

  # Add explicit dependency to ensure CloudFront exists before updating the policy
  depends_on = [aws_cloudfront_distribution.cdn]
}