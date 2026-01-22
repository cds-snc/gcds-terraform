output "hosted_zone_id_cdn" {
  description = "(Alpha) Route53 hosted zone ID that will hold the CDN DNS records"
  value       = aws_route53_zone.content_delivery_network.zone_id
}

output "hosted_zone_id_website_en" {
  description = "(Alpha) Route53 hosted zone ID that will hold the website's English DNS records"
  value       = aws_route53_zone.website_en.zone_id
}

output "hosted_zone_id_website_fr" {
  description = "(Alpha) Route53 hosted zone ID that will hold the website's French DNS records"
  value       = aws_route53_zone.website_fr.zone_id
}

output "hosted_zone_id_ca_cdn" {
  description = "(Canada.ca) Route53 hosted zone ID that will hold the CDN DNS records"
  value       = aws_route53_zone.ca_cdn.zone_id
}

output "hosted_zone_id_ca_website_en" {
  description = "(Canada.ca) Route53 hosted zone ID that will hold the Canadian website's English DNS records"
  value       = aws_route53_zone.ca_website_en.zone_id
}

output "hosted_zone_id_ca_website_fr" {
  description = "(Canada.ca) Route53 hosted zone ID that will hold the Canadian website's French DNS records"
  value       = aws_route53_zone.ca_website_fr.zone_id
}