resource "aws_route53_zone" "website_en" {
  name = var.alpha_domain_website_en

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}

