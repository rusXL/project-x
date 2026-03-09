# variables

variable "gcp_project_id" {
  description = "GCP project ID."
  type        = string
  default     = "cloud-computing-476715"
}

variable "gcp_region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone."
  type        = string
  default     = "us-central1-a"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "gcp_subnet_cidr" {
  description = "CIDR for the GCP subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "rancher_bootstrap_password" {
  description = "Rancher initial admin password."
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "rancher_hostname" {
  description = "Rancher hostname. Leave empty to auto-use <lb-ip>.nip.io (no DNS needed)."
  type        = string
  default     = ""
}
