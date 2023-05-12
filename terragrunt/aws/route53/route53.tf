resource "aws_route53_zone" "domain_en" {
  name = var.domain_en

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_route53_zone" "domain_fr" {
  name = var.domain_fr

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_route53_record" "domain_en_CNAME" {
  zone_id = aws_route53_zone.domain_en.zone_id
  name    = var.domain_en
  type    = "CNAME"
  records = [
    "cds-design-snc.netlify.app"
  ]
  ttl = "300"
}

resource "aws_route53_record" "domain_fr_CNAME" {
  zone_id = aws_route53_zone.domain_fr.zone_id
  name    = var.domain_fr
  type    = "CNAME"
  records = [
    "cds-design-snc.netlify.app"
  ]
  ttl = "300"
}
