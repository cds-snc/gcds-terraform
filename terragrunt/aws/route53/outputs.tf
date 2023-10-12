output "hosted_zone_id_cdn" {
  description = "Route53 hosted zone ID that will hold the CDN DNS records"
  value       = aws_route53_zone.content_delivery_network.zone_id
}

output "hosted_zone_id_website" {
  description = "Route53 hosted zone ID that will hold the website DNS records"
  value       = aws_route53_zone.website.zone_id
}
