# ACM certificate for alpha English website domain (used with CloudFront/Amplify custom domain)

# Note: ACM for CloudFront must be in us-east-1
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "website_alpha_en" {
  provider = aws.us-east-1

  domain_name       = var.alpha_domain_website_en
  validation_method = "DNS"

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation records in the English hosted zone
resource "aws_route53_record" "website_alpha_en_dns_validation" {
  zone_id = var.hosted_zone_id_en

  for_each = {
    for dvo in aws_acm_certificate.website_alpha_en.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type

  ttl = 60
}

resource "aws_acm_certificate_validation" "website_alpha_en_validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.website_alpha_en.arn
  validation_record_fqdns = [for record in aws_route53_record.website_alpha_en_dns_validation : record.fqdn]
}

