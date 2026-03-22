# Cloud DNS private forwarding zone
# Forwards to Route 53 Resolver inbound endpoint IPs over the HA VPN

resource "google_dns_managed_zone" "internal_fwd" {
  name        = "project-x-forwarding-zone"
  dns_name    = "project-x."
  description = "Forwards project-x. queries to Route 53 Resolver over VPN"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = var.vpc_g_id
    }
  }

  forwarding_config {
    dynamic "target_name_servers" {
      for_each = aws_route53_resolver_endpoint.inbound.ip_address
      content {
        ipv4_address    = target_name_servers.value.ip
        forwarding_path = "private"
      }
    }
  }
}
