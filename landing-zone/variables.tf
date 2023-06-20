variable "location" {
  type = string
  default = "WestUS2"
}

variable "resource_group_ml_name" {
  type = string
  default = "rg-aml"
}

variable "resource_group_adf_name" {
  type = string
  default = "rg-adf"
}

variable "application_insights_name" {
  type = string
  default = "mlappinsights"
}

variable "key_vault_name" {
  type = string
  default = "ml-vault"
}

variable "storage_account_name" {
  type = string
  default = "ml-vault"
}

variable "storage_account_tier" {
  type = string
  default = "Standard"
}

variable "storage_account_type" {
  type = string
  default = "GRS"
}

variable "container_registry_name" {
  type = string
  default = "mlbankercr"
}

variable "ml_workspace_name" {
  type = string
  default = "ws-banker"
}

variable "adf_name" {
  type = string
  default = "ws-banker"
}

variable "image_build_compute_name" {
  type = string
  default = "image-builder"
}

variable "private_endpoint_subnet_id" {
  type = string
  default = ""
}

variable "compute_cluster_subnet_id" {
  type = string
  default = ""
}

variable "private_dns_zone_id_key_vault" {
  type = string
  default = ""
}

variable "private_dns_zone_id_str_blob" {
  type = string
  default = ""
}

variable "private_dns_zone_id_str_file" {
  type = string
  default = ""
}

variable "private_dns_zone_id_cr" {
  type = string
  default = ""
}

variable "private_dns_zone_id_mlw" {
  type = string
  default = ""
}

variable "private_dns_zone_id_notebooks" {
  type = string
  default = ""
}

variable "private_dns_zone_id_adf_datafactory" {
  type = string
  default = ""
}

variable "private_dns_zone_id_adf_portal" {
  type = string
  default = ""
}

resource "random_string" "postfix" {
  length = 6
  special = false
  upper = false
}