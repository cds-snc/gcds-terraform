output "hosted_zone_id_cdn" {
  description = "Route53 hosted zone ID that will hold the CDN DNS records"
  value       = aws_route53_zone.content_delivery_network.zone_id
}

output "hosted_zone_id_website_en" {
  description = "Route53 hosted zone ID that will hold the website's English DNS records"
  value       = aws_route53_zone.website_en.zone_id
}

output "hosted_zone_id_website_fr" {
  description = "Route53 hosted zone ID that will hold the website's French DNS records"
  value       = aws_route53_zone.website_fr.zone_id
}
