# Route53 record: point the alpha EN apex domain to the CloudFront distribution (Alias A)
# CloudFront hosted zone ID is a global constant: Z2FDTNDATAQYW2
# resource "aws_route53_record" "alpha_en_redirect_apex" {
#   zone_id = var.hosted_zone_id_en
#   name    = var.alpha_domain_website_en
#   type    = "A"
#
#   allow_overwrite = true
#
#   alias {
#     name                   = aws_cloudfront_distribution.alpha_en_redirect.domain_name
#     zone_id                = "Z2FDTNDATAQYW2"
#     evaluate_target_health = false
#   }
# }
