# eks module variables

variable "rancher_hostname" {
  type = string
}
variable "rancher_token" {
  type      = string
  sensitive = true
}

variable "aws_zone_id" {
  type = string
}
