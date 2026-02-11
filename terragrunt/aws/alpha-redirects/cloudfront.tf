# CloudFront distribution to front the S3 website redirect and provide HTTPS using the existing ACM cert
resource "aws_cloudfront_distribution" "alpha_redirect_en" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Alpha EN domain redirect to ${var.ca_domain_website_en}"

  aliases     = [var.alpha_domain_website_en]
  price_class = "PriceClass_All"

  origin {
    domain_name = aws_s3_bucket_website_configuration.alpha_redirect_en.website_endpoint
    origin_id   = local.s3_alpha_en_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = local.s3_alpha_en_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

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
    bucket = module.alpha_redirect_bucket_fr.s3_bucket_domain_name
    prefix = "platform/gc-design-system/alpha-redirect-logs/"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website_alpha_en.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [aws_acm_certificate_validation.website_alpha_validation_en]
}

# CloudFront distribution to front the S3 website redirect and provide HTTPS using the existing ACM cert
resource "aws_cloudfront_distribution" "alpha_redirect_fr" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "Alpha FR domain redirect to ${var.ca_domain_website_fr}"

  aliases     = [var.alpha_domain_website_fr]
  price_class = "PriceClass_All"

  origin {
    domain_name = aws_s3_bucket_website_configuration.alpha_redirect_fr.website_endpoint
    origin_id   = local.s3_alpha_fr_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = local.s3_alpha_fr_origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress = true

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

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
    bucket = module.alpha_redirect_bucket_fr.s3_bucket_domain_name
    prefix = "platform/gc-design-system/alpha-redirect-logs/"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website_alpha_fr.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [aws_acm_certificate_validation.website_alpha_validation_fr]
}