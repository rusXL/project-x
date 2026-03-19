# GCP HA VPN

module "vpn_ha" {
  source  = "terraform-google-modules/vpn/google//modules/vpn_ha"
  version = "~> 4.2"

  project_id = var.gcp_project_id
  region     = var.gcp_region
  name       = "vpn-gw-g"
  network    = var.vpc_g_id
  router_asn = var.gcp_bgp_asn

  peer_external_gateway = {
    redundancy_type = "FOUR_IPS_REDUNDANCY"
    interfaces = [
      { id = 0, ip_address = module.vpn_conn_0.vpn_connection_tunnel1_address },
      { id = 1, ip_address = module.vpn_conn_0.vpn_connection_tunnel2_address },
      { id = 2, ip_address = module.vpn_conn_1.vpn_connection_tunnel1_address },
      { id = 3, ip_address = module.vpn_conn_1.vpn_connection_tunnel2_address },
    ]
  }

  tunnels = {
    tunnel-0 = {
      bgp_peer = {
        address = module.vpn_conn_0.vpn_connection_tunnel1_vgw_inside_address
        asn     = var.aws_bgp_asn
      }
      bgp_session_range               = "${module.vpn_conn_0.vpn_connection_tunnel1_cgw_inside_address}/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 0
      shared_secret                   = var.vpn_psk
      bgp_peer_options                = { route_priority = 100 }
    }

    tunnel-1 = {
      bgp_peer = {
        address = module.vpn_conn_0.vpn_connection_tunnel2_vgw_inside_address
        asn     = var.aws_bgp_asn
      }
      bgp_session_range               = "${module.vpn_conn_0.vpn_connection_tunnel2_cgw_inside_address}/30"
      ike_version                     = 2
      vpn_gateway_interface           = 0
      peer_external_gateway_interface = 1
      shared_secret                   = var.vpn_psk
      bgp_peer_options                = { route_priority = 100 }
    }

    tunnel-2 = {
      bgp_peer = {
        address = module.vpn_conn_1.vpn_connection_tunnel1_vgw_inside_address
        asn     = var.aws_bgp_asn
      }
      bgp_session_range               = "${module.vpn_conn_1.vpn_connection_tunnel1_cgw_inside_address}/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 2
      shared_secret                   = var.vpn_psk
      bgp_peer_options                = { route_priority = 100 }
    }

    tunnel-3 = {
      bgp_peer = {
        address = module.vpn_conn_1.vpn_connection_tunnel2_vgw_inside_address
        asn     = var.aws_bgp_asn
      }
      bgp_session_range               = "${module.vpn_conn_1.vpn_connection_tunnel2_cgw_inside_address}/30"
      ike_version                     = 2
      vpn_gateway_interface           = 1
      peer_external_gateway_interface = 3
      shared_secret                   = var.vpn_psk
      bgp_peer_options                = { route_priority = 100 }
    }
  }
}
