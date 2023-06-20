# Dependent resources for Azure Machine Learning
resource "azurerm_application_insights" "default" {
  name                = var.application_insights_name
  location            = azurerm_resource_group.ml.location
  resource_group_name = azurerm_resource_group.ml.name
  application_type    = "web"
}

resource "azurerm_key_vault" "default" {
  name                     = var.key_vault_name
  location                 = azurerm_resource_group.ml.location
  resource_group_name      = azurerm_resource_group.ml.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  sku_name                 = "premium"
  purge_protection_enabled = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

resource "azurerm_storage_account" "default" {
  name                     = var.storage_account_name
  location                 = azurerm_resource_group.ml.location
  resource_group_name      = azurerm_resource_group.ml.name
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_type

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }
}

resource "azurerm_container_registry" "default" {
  name                = var.container_registry_name
  location            = azurerm_resource_group.ml.location
  resource_group_name = azurerm_resource_group.ml.name
  sku                 = "Premium"
  admin_enabled       = true

  network_rule_set {
    default_action = "Deny"
  }
  public_network_access_enabled = false
}
#
### Machine Learning workspace
resource "azurerm_machine_learning_workspace" "default" {
  name                    = var.ml_workspace_name
  location                = azurerm_resource_group.ml.location
  resource_group_name     = azurerm_resource_group.ml.name
  application_insights_id = azurerm_application_insights.default.id
  key_vault_id            = azurerm_key_vault.default.id
  storage_account_id      = azurerm_storage_account.default.id
  container_registry_id   = azurerm_container_registry.default.id

  identity {
    type = "SystemAssigned"
  }

  # Args of use when using an Azure Private Link configuration
  public_network_access_enabled = false
  image_build_compute_name      = var.image_build_compute_name
}

## Private endpoints
resource "azurerm_private_endpoint" "kv_ple" {
  name                = "ple-${var.key_vault_name}"
  location            = azurerm_resource_group.ml.location
  resource_group_name = azurerm_resource_group.ml.name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id_key_vault]
  }

  private_service_connection {
    name                           = "psc-${var.key_vault_name}"
    private_connection_resource_id = azurerm_key_vault.default.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}


resource "azurerm_private_endpoint" "st_ple_blob" {
  name                = "ple-${var.storage_account_name}-blob"
  location            = azurerm_resource_group.ml.location
  resource_group_name = azurerm_resource_group.ml.name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id_str_blob]
  }

  private_service_connection {
    name                           = "psc-${var.storage_account_name}-blob"
    private_connection_resource_id = azurerm_storage_account.default.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "storage_ple_file" {
  name                = "ple-${var.storage_account_name}-file"
  location            = azurerm_resource_group.ml.location
  resource_group_name = azurerm_resource_group.ml.name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id_str_file]
  }

  private_service_connection {
    name                           = "psc-${var.storage_account_name}-file"
    private_connection_resource_id = azurerm_storage_account.default.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "cr_ple" {
  name                = "ple-${var.container_registry_name}"
  location            = azurerm_resource_group.ml.location
  resource_group_name = azurerm_resource_group.ml.name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id_cr]
  }

  private_service_connection {
    name                           = "psc-${var.container_registry_name}"
    private_connection_resource_id = azurerm_container_registry.default.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}

resource "azurerm_private_endpoint" "mlw_ple" {
  name                = "ple-${var.ml_workspace_name}"
  location            = azurerm_resource_group.ml.location
  resource_group_name = azurerm_resource_group.ml.name
  subnet_id           = var.private_endpoint_subnet_id

  private_dns_zone_group {
    name                 = "private-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id_mlw, var.private_dns_zone_id_notebooks]
  }

  private_service_connection {
    name                           = "psc-${var.ml_workspace_name}"
    private_connection_resource_id = azurerm_machine_learning_workspace.default.id
    subresource_names              = ["amlworkspace"]
    is_manual_connection           = false
  }
}

## Compute cluster 
resource "azurerm_machine_learning_compute_cluster" "image-builder" {
  name                          = var.image_build_compute_name
  location                      = azurerm_resource_group.ml.location
  vm_priority                   = "LowPriority"
  vm_size                       = "STANDARD_D2S_V3"
  machine_learning_workspace_id = azurerm_machine_learning_workspace.default.id
  subnet_resource_id            = var.compute_cluster_subnet_id

  scale_settings {
    min_node_count                       = 0
    max_node_count                       = 3
    scale_down_nodes_after_idle_duration = "PT15M" # 15 minutes
  }

  identity {
    type = "SystemAssigned"
  }
}