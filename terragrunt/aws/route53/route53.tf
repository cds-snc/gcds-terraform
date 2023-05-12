resource "aws_route53_zone" "content_delivery_network" {
  name = var.domain_cdn

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}
