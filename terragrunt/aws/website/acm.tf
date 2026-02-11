# ACM certificate for alpha website domains
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

resource "aws_acm_certificate" "website_alpha_fr" {
  provider = aws.us-east-1

  domain_name       = var.alpha_domain_website_fr
  validation_method = "DNS"

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create DNS validation records in the EN and FR hosted zones
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

resource "aws_route53_record" "website_alpha_fr_dns_validation" {
  zone_id = var.hosted_zone_id_fr

  for_each = {
    for dvo in aws_acm_certificate.website_alpha_fr.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "website_alpha_fr_validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.website_alpha_fr.arn
  validation_record_fqdns = [for record in aws_route53_record.website_alpha_fr_dns_validation : record.fqdn]
}