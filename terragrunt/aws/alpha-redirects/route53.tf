// Route53 record: point the alpha EN apex domain to the CloudFront distribution (Alias A)
// CloudFront hosted zone ID can be sourced from the distribution resource
resource "aws_route53_record" "alpha_fr_redirect_A" {
  zone_id = var.hosted_zone_id_fr
  name    = var.alpha_domain_website_fr
  type    = "A"

  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.alpha_redirect_fr.domain_name
    zone_id                = aws_cloudfront_distribution.alpha_redirect_fr.hosted_zone_id
    evaluate_target_health = false
  }
}
