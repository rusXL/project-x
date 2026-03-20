
variable "rancher_admin_password" {
  description = "Rancher final admin password (replaces bootstrap password)."
  type        = string
  sensitive   = true
}
