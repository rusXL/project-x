
variable "rancher_admin_password" {
  description = "Rancher final admin password (replaces bootstrap password)."
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Grafana admin password."
  type        = string
  sensitive   = true
}
