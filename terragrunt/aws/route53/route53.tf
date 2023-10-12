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