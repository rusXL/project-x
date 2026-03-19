# variables

variable "rancher_hostname" {
  description = "Rancher hostname."
  type        = string
}

variable "rancher_admin_password" {
  description = "Rancher initial admin password."
  type        = string
  sensitive   = true
}

variable "gke_lb_ip" {
  description = "GKE load balancer IP."
  type        = string
}
