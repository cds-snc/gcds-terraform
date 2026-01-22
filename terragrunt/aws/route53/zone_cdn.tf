resource "aws_route53_zone" "content_delivery_network" {
  name = var.alpha_domain_cdn

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_route53_record" "cdn_NS" {
  zone_id = aws_route53_zone.website_en.zone_id
  name    = var.alpha_domain_cdn

  type = "NS"

  records = aws_route53_zone.content_delivery_network.name_servers
  ttl     = "300"
}

resource "aws_route53_zone" "ca_cdn" {
  name = var.ca_domain_cdn

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_route53_record" "ca_cdn_NS" {
  zone_id = aws_route53_zone.ca_website_en.zone_id
  name    = var.ca_domain_cdn

  type = "NS"

  records = aws_route53_zone.ca_cdn.name_servers
  ttl     = "300"
}

