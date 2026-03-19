# root variables

# --- GKE ---
variable "gke_endpoint" {
  description = "GKE cluster API endpoint."
  type        = string
  sensitive   = true
}
variable "gke_ca_cert" {
  description = "GKE cluster CA certificate (base64)."
  type        = string
  sensitive   = true
}
variable "gke_token" {
  description = "GKE access token."
  type        = string
  sensitive   = true
}
variable "gke_lb_ip" {
  description = "GKE load balancer IP."
  type        = string
}

# --- EKS ---
variable "eks_endpoint" {
  description = "EKS cluster API endpoint."
  type        = string
  sensitive   = true
}
variable "eks_ca_cert" {
  description = "EKS cluster CA certificate (base64)."
  type        = string
  sensitive   = true
}
variable "eks_token" {
  description = "EKS access token."
  type        = string
  sensitive   = true
}


# --- Rancher ---
variable "rancher_hostname" {
  description = "Rancher hostname (e.g. rancher.example.com)."
  type        = string
}
variable "rancher_admin_password" {
  description = "Rancher final admin password (replaces bootstrap password)."
  type        = string
  sensitive   = true
}
