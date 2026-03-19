# AWS VPN Gateway (+ connections)

resource "aws_vpn_gateway" "vpn_gw_a" {
  vpc_id          = var.vpc_a_id
  amazon_side_asn = var.aws_bgp_asn

  tags = { Name = "vpn-gw-a" }
}

resource "aws_customer_gateway" "cgw_0" {
  bgp_asn    = var.gcp_bgp_asn
  ip_address = module.vpn_ha.gateway[0].vpn_interfaces[0].ip_address
  type       = "ipsec.1"

  tags = { Name = "cgw-g-if0" }
}

resource "aws_customer_gateway" "cgw_1" {
  bgp_asn    = var.gcp_bgp_asn
  ip_address = module.vpn_ha.gateway[0].vpn_interfaces[1].ip_address
  type       = "ipsec.1"

  tags = { Name = "cgw-g-if1" }
}

module "vpn_conn_0" {
  source  = "terraform-aws-modules/vpn-gateway/aws"
  version = "~> 3.0"

  vpn_gateway_id      = aws_vpn_gateway.vpn_gw_a.id
  customer_gateway_id = aws_customer_gateway.cgw_0.id

  vpc_id                        = var.vpc_a_id
  vpc_subnet_route_table_ids    = [var.route_table_a_id]
  vpc_subnet_route_table_count  = 1
  create_vpn_gateway_attachment = false

  tunnel1_preshared_key = var.vpn_psk
  tunnel2_preshared_key = var.vpn_psk

  tags = { Name = "vpn-conn-g-if0" }
}

module "vpn_conn_1" {
  source  = "terraform-aws-modules/vpn-gateway/aws"
  version = "~> 3.0"

  vpn_gateway_id      = aws_vpn_gateway.vpn_gw_a.id
  customer_gateway_id = aws_customer_gateway.cgw_1.id

  vpc_id                        = var.vpc_a_id
  create_vpn_gateway_attachment = false

  tunnel1_preshared_key = var.vpn_psk
  tunnel2_preshared_key = var.vpn_psk

  tags = { Name = "vpn-conn-g-if1" }
}
