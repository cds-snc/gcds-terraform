resource "aws_ssm_parameter" "gcds_api_config" {
  provider = aws.core_services
  name     = "${var.product_name}-config"
  type     = "SecureString"
  value    = var.api_config

  tags = {
    CostCentre = var.billing_code
    Terraform  = true
  }
}