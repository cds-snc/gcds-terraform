resource "aws_route53_zone" "content_delivery_network" {
  name = var.domain_cdn

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_route53_zone" "website_en" {
  name = var.domain_website_en

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_route53_zone" "website_fr" {
  name = var.domain_website_fr

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_route53_record" "cdn_NS" {
  zone_id = aws_route53_zone.website_en.zone_id
  name    = var.domain_cdn

  type    = "NS"

  records = [
    "ns-1114.awsdns-11.org",
    "ns-830.awsdns-39.net",
    "ns-2010.awsdns-59.co.uk",
    "ns-111.awsdns-13.com"
  ]
  ttl = "300"
}