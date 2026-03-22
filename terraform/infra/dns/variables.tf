variable "vpc_a_id" {
  description = "AWS VPC ID."
  type        = string
}

variable "subnet_a_id" {
  description = "AWS subnet A ID for Route 53 Resolver endpoint."
  type        = string
}

variable "subnet_b_id" {
  description = "AWS subnet B ID for Route 53 Resolver endpoint."
  type        = string
}

variable "vpc_g_id" {
  description = "GCP VPC self-link for Cloud DNS private zone binding."
  type        = string
}

variable "gcp_subnet_cidr" {
  description = "GCP subnet CIDR — allowed to query the Route 53 Resolver."
  type        = string
}

variable "aws_vpc_cidr" {
  description = "AWS VPC CIDR — allowed to query the Route 53 Resolver."
  type        = string
}

