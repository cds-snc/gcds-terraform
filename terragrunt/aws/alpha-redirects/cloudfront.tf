# CloudFront distribution to front the S3 website redirect and provide HTTPS using the existing ACM cert
resource "aws_cloudfront_distribution" "alpha_en_redirect" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Alpha EN domain redirect to ${var.ca_domain_website_en}"

  aliases = [var.alpha_domain_website_en]
  price_class = "PriceClass_All"

  origin {
    domain_name = aws_s3_bucket_website_configuration.alpha_redirect_en.website_endpoint
    origin_id   = local.s3_alpha_en_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = local.s3_alpha_en_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website_alpha_en.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [aws_acm_certificate_validation.website_alpha_validation_en]
}

# CloudFront distribution to front the S3 website redirect and provide HTTPS using the existing ACM cert
resource "aws_cloudfront_distribution" "alpha_fr_redirect" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Alpha FR domain redirect to ${var.ca_domain_website_fr}"

  aliases = [var.alpha_domain_website_fr]
  price_class = "PriceClass_All"

  origin {
    domain_name = aws_s3_bucket_website_configuration.alpha_redirect_fr.website_endpoint
    origin_id   = local.s3_alpha_fr_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = local.s3_alpha_fr_origin_id
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website_alpha_fr.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  depends_on = [aws_acm_certificate_validation.website_alpha_validation_fr]
}