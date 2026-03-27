# variables

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

variable "aws_node_count" {
  description = "Node count for EKS node group."
  type        = number
}

variable "aws_instance_type" {
  description = "EC2 instance type for EKS nodes."
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

variable "gcp_vpc_cidr" {
  description = "GCP VPC CIDR — for security group ingress rule."
  type        = string
}

variable "gcp_pod_cidr" {
  description = "GCP POD CIDR — for security group ingress rule."
  type        = string
}


