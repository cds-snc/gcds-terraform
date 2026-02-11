# S3 bucket to host website redirect from alpha EN domain to canonical CA EN domain
module "alpha_en_redirect_bucket" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v10.6.2"
  bucket_name       = var.alpha_domain_redirect_en
  billing_tag_value = var.billing_code
}

# S3 bucket to host website redirect from alpha FR domain to canonical CA FR domain
module "alpha_fr_redirect_bucket" {
  source            = "github.com/cds-snc/terraform-modules//S3?ref=v10.6.2"
  bucket_name       = var.alpha_domain_redirect_fr
  billing_tag_value = var.billing_code
}


# Configure S3 static website hosting to redirect all requests to the CA EN domain (HTTPS)
resource "aws_s3_bucket_website_configuration" "alpha_en_redirect" {
  bucket = module.alpha_en_redirect_bucket.s3_bucket_id

  redirect_all_requests_to {
    host_name = var.ca_domain_website_en
    protocol  = "https"
  }
}

# Configure S3 static website hosting to redirect all requests to the CA FR domain (HTTPS)
resource "aws_s3_bucket_website_configuration" "alpha_fr_redirect" {
  bucket = module.alpha_fr_redirect_bucket.s3_bucket_id

  redirect_all_requests_to {
    host_name = var.ca_domain_website_fr
    protocol  = "https"
  }
}

# CloudFront distribution to front the S3 website redirect and provide HTTPS using the existing ACM cert
resource "aws_cloudfront_distribution" "alpha_en_redirect" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Alpha EN domain redirect to ${var.ca_domain_website_en}"
  default_root_object = ""

  aliases = [var.alpha_domain_website_en]

  origin {
    domain_name = aws_s3_bucket_website_configuration.alpha_en_redirect.website_endpoint
    origin_id   = "s3-website-redirect-alpha-en"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-website-redirect-alpha-en"
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

  price_class = "PriceClass_All"

  depends_on = [aws_acm_certificate_validation.website_alpha_en_validation]
}

# CloudFront distribution to front the S3 website redirect and provide HTTPS using the existing ACM cert
resource "aws_cloudfront_distribution" "alpha_fr_redirect" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Alpha FR domain redirect to ${var.ca_domain_website_fr}"
  default_root_object = ""

  aliases = [var.alpha_domain_website_fr]

  origin {
    domain_name = aws_s3_bucket_website_configuration.alpha_fr_redirect.website_endpoint
    origin_id   = "s3-website-redirect-alpha-fr"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "s3-website-redirect-alpha-fr"
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

  price_class = "PriceClass_All"

  depends_on = [aws_acm_certificate_validation.website_alpha_fr_validation]
}

# Route53 record: point the alpha EN apex domain to the CloudFront distribution (Alias A)
# CloudFront hosted zone ID is a global constant: Z2FDTNDATAQYW2
# resource "aws_route53_record" "alpha_en_redirect_apex" {
#   zone_id = var.hosted_zone_id_en
#   name    = var.alpha_domain_website_en
#   type    = "A"
#
#   allow_overwrite = true
#
#   alias {
#     name                   = aws_cloudfront_distribution.alpha_en_redirect.domain_name
#     zone_id                = "Z2FDTNDATAQYW2"
#     evaluate_target_health = false
#   }
# }

