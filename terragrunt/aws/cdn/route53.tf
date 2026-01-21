resource "aws_route53_record" "cdn_A" {
  zone_id = var.hosted_zone_id
  name    = var.domain_cdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}
