# variables

variable "gcp_node_count" {
  description = "Node count for cluster."
  type        = number
}

variable "gcp_machine_type" {
  description = "Machine type for GKE nodes."
  type        = string
}

variable "gcp_region" {
  description = "GCP region."
  type        = string
}


variable "gcp_zone" {
  description = "GCP zone."
  type        = string
}

variable "gcp_subnet_cidr" {
  description = "CIDR for the GCP subnet."
  type        = string
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR — for firewall ingress rule."
  type        = string
}
