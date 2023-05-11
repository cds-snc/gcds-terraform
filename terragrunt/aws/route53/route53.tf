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
