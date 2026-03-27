# GCP
variable "gcp_project_id" {
  description = "GCP project ID."
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
variable "gcp_node_count" {
  description = "Node count for GKE cluster."
  type        = number
}
variable "gcp_machine_type" {
  description = "Machine type for GKE nodes."
  type        = string
}

# AWS
variable "aws_region" {
  description = "AWS region."
  type        = string
}
variable "aws_zone" {
  description = "AWS availability zone."
  type        = string
}
variable "aws_vpc_cidr" {
  description = "CIDR for the AWS VPC."
  type        = string
}
variable "aws_subnet_cidr" {
  description = "CIDR for the AWS subnet."
  type        = string
}
variable "aws_subnet_b_cidr" {
  description = "CIDR block for EKS subnet B."
  type        = string
}
variable "aws_zone_b" {
  description = "AWS availability zone for subnet B."
  type        = string
}
variable "aws_node_count" {
  description = "Node count for EKS cluster."
  type        = number
}
variable "aws_instance_type" {
  description = "EC2 instance type for EKS nodes."
  type        = string
}

# VPN
variable "vpn_psk" {
  description = "Pre-shared key for VPN tunnels."
  type        = string
  sensitive   = true
}
