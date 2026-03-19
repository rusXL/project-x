variable "vpc_g_id" {
  description = "GCP VPC ID."
  type        = string
}

variable "vpc_a_id" {
  description = "AWS VPC ID."
  type        = string
}

variable "route_table_a_id" {
  description = "AWS route table ID for VPN route propagation."
  type        = string
}

variable "gcp_project_id" {
  description = "GCP project ID."
  type        = string
}

variable "gcp_region" {
  description = "GCP region."
  type        = string
}

variable "gcp_bgp_asn" {
  description = "BGP ASN for GCP Cloud Router."
  type        = number
  default     = 64514
}

variable "aws_bgp_asn" {
  description = "BGP ASN for AWS VPN Gateway."
  type        = number
  default     = 64512
}

variable "vpn_psk" {
  description = "Pre-shared key for VPN tunnels."
  type        = string
  sensitive   = true
}
