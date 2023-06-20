data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "ml" {
  name     = var.resource_group_ml_name
  location = var.location
}

resource "azurerm_resource_group" "adf" {
  name     = var.resource_group_adf_name
  location = var.location
}