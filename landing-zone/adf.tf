resource "azurerm_data_factory" "adf" {
  name                   = var.adf_name
  resource_group_name    = azurerm_resource_group.adf.name
  location               = var.location
  public_network_enabled = false
}

resource "azurerm_private_endpoint" "adf_ple_portal" {
  name                = "ple-${var.adf_name}-portal"
  location            = azurerm_resource_group.adf.location
  resource_group_name = azurerm_resource_group.adf.name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id_adf_portal]
  }

  private_service_connection {
    name                           = "psc-${var.adf_name}-portal"
    private_connection_resource_id = azurerm_data_factory.adf.id
    subresource_names              = ["portal"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "adf_ple_datafactory" {
  name                = "ple-${var.adf_name}-df"
  location            = azurerm_resource_group.adf.location
  resource_group_name = azurerm_resource_group.adf.name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id_adf_datafactory]
  }

  private_service_connection {
    name                           = "psc-${var.adf_name}-df"
    private_connection_resource_id = azurerm_data_factory.adf.id
    subresource_names              = ["dataFactory"]
    is_manual_connection           = false
  }
}

