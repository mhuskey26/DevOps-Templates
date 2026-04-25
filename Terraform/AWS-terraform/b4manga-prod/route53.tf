# DNS Management with Cloudflare
#
# Route 53 DNS records have been removed in favor of Cloudflare for DNS and SSL/TLS management.
#
# To configure your domain with Cloudflare:
# 1. Set cloudflare_zone_id and cloudflare_api_token variables
# 2. Log in to Cloudflare dashboard
# 3. Add a DNS A record pointing to the ALB: ${aws_lb.main.dns_name}
# 4. Enable Cloudflare proxy (orange cloud) for automatic HTTPS
#
# See terraform.tfvars.example for Cloudflare configuration options.
# See DEPLOYMENT.md for detailed setup instructions.
