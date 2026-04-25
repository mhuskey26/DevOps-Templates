# Route 53 DNS Record (optional)
# Only create if route53_zone_id is provided

resource "aws_route53_record" "wordpress" {
  count           = var.route53_zone_id != "" ? 1 : 0
  zone_id         = var.route53_zone_id
  name            = var.domain_name
  type            = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# www subdomain (optional)
resource "aws_route53_record" "wordpress_www" {
  count           = var.route53_zone_id != "" ? 1 : 0
  zone_id         = var.route53_zone_id
  name            = "www.${var.domain_name}"
  type            = "A"
  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# Outputs
output "route53_record_fqdn" {
  value       = var.route53_zone_id != "" ? aws_route53_record.wordpress[0].fqdn : "Not configured"
  description = "FQDN of the Route 53 record"
}
