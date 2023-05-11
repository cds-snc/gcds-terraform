resource "aws_route53_zone" "gcds" {
  name = var.domain

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}
