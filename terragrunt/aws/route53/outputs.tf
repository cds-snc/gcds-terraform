output "hosted_zone_id" {
  description = "Route53 hosted zone ID that will hold the CDN DNS records.  Once the new `hosted_zone_id_cdn` output has been created, this can be removed and the `cdn` module can be updated."
  value       = aws_route53_zone.content_delivery_network.zone_id
}

output "hosted_zone_id_cdn" {
  description = "Route53 hosted zone ID that will hold the CDN DNS records"
  value       = aws_route53_zone.content_delivery_network.zone_id
}

output "hosted_zone_id_website" {
  description = "Route53 hosted zone ID that will hold the website DNS records"
  value       = aws_route53_zone.website.zone_id
}
