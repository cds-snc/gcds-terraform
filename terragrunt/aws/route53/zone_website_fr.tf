resource "aws_route53_zone" "website_fr" {
  name = var.alpha_domain_website_fr

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

resource "aws_route53_zone" "ca_website_fr" {
  name = var.ca_domain_website_fr

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}